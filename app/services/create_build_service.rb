class CreateBuildService
  def execute(project, params)
    new_build = prepare_new_build(params)

    if new_build.valid?
      build_config_params = load_build_config_params(project, new_build.ref, new_build.sha)
      # TODO process params and create more builds by params
      new_build.parameters = build_config_params
    end

    new_build.project = project
    new_build.save
    new_build
  end

  private

  def prepare_new_build(params)
    if params.kind_of?(Build)
      new_build = params.dup
      new_build.status = :pending
      new_build.finished_at = nil
      new_build.trace = nil
      new_build.started_at = nil
      new_build.runner_id = nil
      new_build.parameters = nil
    else
      before_sha = params[:before]
      sha = params[:after]
      ref = params[:ref]

      if ref && ref.include?('refs/heads/')
        ref = ref.scan(/heads\/(.*)$/).flatten[0]
      end

      data = {
        ref: ref,
        sha: sha,
        before_sha: before_sha,
        push_data: params
      }
      new_build = Build.new(data)
    end
    new_build
  end

  def load_build_config_params(project, ref, sha)
    Rails.cache.fetch(cache_key(project, ref, sha)) do
      network = Network.new

      gitlab_url = URI.parser.parse(project.gitlab_url)
      request_url = gitlab_url.scheme + '://' + gitlab_url.host
      repo_files = network.list_repository_tree(request_url, project.gitlab_id, project.private_token, ref)
      if repo_files != nil
        gitlab_files = repo_files.select! do |file|
          file['type'] == 'blob' and file['name'] == '.gitlab.yml'
        end
        if gitlab_files != nil and gitlab_files.length > 0
          gitlab_file_content = network.raw_file_content(request_url, project.gitlab_id, project.private_token, sha, gitlab_files.first['name'])
          if gitlab_file_content != nil
            return YAML.load(gitlab_file_content)
          end
        end
      end
      nil
    end
  end

  def cache_key(project, ref, sha)
    "#{project.id}:#{ref}:#{sha}"
  end
end

class LoadBuildConfigFileService
  def load(project, ref, sha)
    Rails.cache.fetch(cache_key(project, ref, sha)) do
      content = file_content(project, ref, sha)
      return YAML.load(content) unless content.nil?
      nil
    end
  end

  private

  def cache_key(project, ref, sha)
    "#{project.id}:#{project.gitlab_id}:#{ref}:#{sha}"
  end

  def file(project, ref_name)
    repo_files = network.list_repository_tree(url(project), project.gitlab_id, project.private_token, ref_name)
    if repo_files != nil
      gitlab_files = repo_files.select! do |file|
        file['type'] == 'blob' and file['name'] == '.gitlab.yml'
      end
      if gitlab_files != nil and gitlab_files.length > 0
        return gitlab_files.first
      end
    end
    nil
  end

  def file_content(project, ref_name, sha)
    gitlab_file = file(project, ref_name)
    if gitlab_file != nil
      return network.raw_file_content(url(project), project.gitlab_id, project.private_token, sha, gitlab_file['name'])
    end
    nil
  end

  def url(project)
    gitlab_url = URI.parser.parse(project.gitlab_url)
    gitlab_url.scheme + '://' + gitlab_url.host
  end

  def network
    @network = Network.new if @network.nil?
    @network
  end
end

class CreateBuildService
  def execute(project, params)
    new_build = prepare_new_build(params)
    new_build.project = project

    if new_build.valid?
      build_config_params = LoadBuildConfigFileService.new.load(project, new_build.ref, new_build.sha)
      unless build_config_params.nil?
        GenerateBuildsByConfigService.new.builds(build_config_params, new_build) do |build, parameters|
          build.parameters = parameters
          build.save
          new_build = build
        end
      end
    end

    new_build.save
    new_build
  end

  private

  def prepare_new_build(params)
    if params.kind_of?(Build)
      new_build = prepare_from_build params
    else
      new_build = prepare_from_hash params
    end
    new_build
  end

  def prepare_from_build(build)
    new_build = build.dup
    new_build.status = :pending
    new_build.finished_at = nil
    new_build.trace = nil
    new_build.started_at = nil
    new_build.runner_id = nil
    new_build.parameters = nil
    new_build
  end

  def prepare_from_hash(hash)
    before_sha = hash[:before]
    sha = hash[:after]
    ref = hash[:ref]

    if ref && ref.include?('refs/heads/')
      ref = ref.scan(/heads\/(.*)$/).flatten[0]
    end

    data = {
      ref: ref,
      sha: sha,
      before_sha: before_sha,
      push_data: hash
    }
    Build.new(data)
  end
end

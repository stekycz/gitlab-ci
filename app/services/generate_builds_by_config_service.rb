class GenerateBuildsByConfigService
  def builds(build_config_params, default_build, &block)
    raise 'block must be specified' unless block_given?

    parameters = {
      language: build_config_params['language'],
      script: build_config_params['script'],
    }

    params_for_combinations = build_config_params.dup
    params_for_combinations.delete('language')
    params_for_combinations.delete('script')

    if params_for_combinations.length > 0
      combinations(params_for_combinations.dup) do |env|
        p = parameters.dup
        p[:env] = env
        block.call(default_build.dup, p)
      end
    else
      yield default_build.dup, parameters
    end
  end

  private

  def combinations(params, combination = {}, &block)
    raise 'block must be specified' unless block_given?

    key = params.keys.first
    params.delete(key).each do |version|
      c = combination.dup
      c[key] = version
      if params.length > 0
        combinations(params.dup, c) { |x| yield x }
      else
        block.call(c)
      end
    end
  end
end

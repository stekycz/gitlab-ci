class Network
  include HTTParty

  API_PREFIX = '/api/v3/'

  def authenticate(url, api_opts)
    opts = {
      body: api_opts.to_json,
      headers: {"Content-Type" => "application/json"},
    }

    endpoint = File.join(url, API_PREFIX, 'session.json')
    response = self.class.post(endpoint, opts)

    if response.code == 201
      response.parsed_response
    else
      nil
    end
  end

  def authenticate_by_token(url, api_opts)
    opts = {
      query: api_opts,
      headers: {"Content-Type" => "application/json"},
    }

    endpoint = File.join(url, API_PREFIX, 'user.json')
    response = self.class.get(endpoint, opts)

    if response.code == 200
      response.parsed_response
    else
      nil
    end
  end


  def projects(url, api_opts, scope = :owned)
    opts = {
      query: api_opts,
      headers: {"Content-Type" => "application/json"},
    }

    query = if scope == :owned
             'projects/owned.json'
            else
             'projects.json'
            end

    endpoint = File.join(url, API_PREFIX, query)
    response = self.class.get(endpoint, opts)

    if response.code == 200
      response.parsed_response
    else
      nil
    end
  end

  def project(url, api_opts, project_id)
    opts = {
      query: api_opts,
      headers: {"Content-Type" => "application/json"},
    }

    query = "projects/#{project_id}.json"

    endpoint = File.join(url, API_PREFIX, query)
    response = self.class.get(endpoint, opts)

    if response.code == 200
      response.parsed_response
    else
      nil
    end
  end

  def list_repository_tree(url, project_id, token, ref_name = 'master', path = '')
    opts = {
        headers: {"Content-Type" => "application/json"},
    }

    query = "projects/#{project_id}/repository/tree.json?private_token=#{token}&ref_name=#{ref_name}&path=#{path}"

    endpoint = File.join(url, API_PREFIX, query)
    response = self.class.get(endpoint, opts)

    if response.code == 200
      response.parsed_response
    else
      []
    end
  end

  def raw_file_content(url, project_id, token, sha, filepath)
    opts = {
      headers: {"Content-Type" => "application/json"},
    }

    query = "projects/#{project_id}/repository/blobs/#{sha}?private_token=#{token}&filepath=#{filepath}"

    endpoint = File.join(url, API_PREFIX, query)
    response = self.class.get(endpoint, opts)

    if response.code == 200
      response.parsed_response
    else
      nil
    end
  end

  def enable_ci(url, project_id, ci_opts, token)
    opts = {
      body: ci_opts.to_json,
      headers: {"Content-Type" => "application/json"},
    }

    query = "projects/#{project_id}/services/gitlab-ci.json?private_token=#{token}"
    endpoint = File.join(url, API_PREFIX, query)
    response = self.class.put(endpoint, opts)

    if response.code == 200
      true
    else
      nil
    end
  end

  def disable_ci(url, project_id, token)
    opts = {
      headers: {"Content-Type" => "application/json"},
    }

    query = "projects/#{project_id}/services/gitlab-ci.json?private_token=#{token}"

    endpoint = File.join(url, API_PREFIX, query)
    response = self.class.delete(endpoint, opts)

    if response.code == 200
      response.parsed_response
    else
      nil
    end
  end
end

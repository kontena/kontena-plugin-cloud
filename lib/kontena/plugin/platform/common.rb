module Kontena::Plugin::Platform::Common
  def fetch_platforms
    all = []
    organizations = cloud_client.get('/organizations')['data']
    organizations.each do |org|
      all = all + fetch_platforms_for_org(org['id'])
    end
    all
  end

  # @param [String] org_id
  # @return [Array<Hash>]
  def fetch_platforms_for_org(org_id)
    platforms = cloud_client.get("/organizations/#{org_id}/platforms")['data']
    platforms.map do |p|
      p['name'] = "#{org_id}/#{p.dig('attributes', 'name')}"
      p.merge({
        'name' => "#{org_id}/#{p.dig('attributes', 'name')}",
        'org_id' => org_id
      })
    end
  end
end
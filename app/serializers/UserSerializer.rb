class UserSerializer
  include RestPack::Serializer

  attributes :login, :id, :avatar_url, :gravatar_id, :url, :html_url, :followers_url, :following_url,
            :gists_url, :starred_url, :subscriptions_url, :organizations_url, :repos_url, :events_url,
            :received_events_url, :type, :site_admin, :name, :company, :blog, :location, :email,
            :hireable, :bio, :public_repos, :public_gists, :followers, :following, :created_at,
            :updated_at
end

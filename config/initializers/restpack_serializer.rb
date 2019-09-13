Dir[Rails.root.join('app/serializers/**/*.rb')].each do |path|
  require path
end

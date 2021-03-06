module Octodmin::Views::Posts
  class Index
    include Octodmin::View
    format :json

    def render
      JSON.dump(posts: posts.map(&:serializable_hash))
    end
  end
end

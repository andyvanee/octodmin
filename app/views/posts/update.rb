module Octodmin::Views::Posts
  class Update
    include Octodmin::View
    format :json

    def render
      JSON.dump(posts: post.serializable_hash)
    end
  end
end

# A meme on memerator
class Memerator::Meme
  # @!visibility private
  def initialize(data, token: nil)
    @data = data
    @token = token
  end

  # @group Meme Information Methods

  # @return [String] the meme's ID.
  def memeid
    @data['memeid']
  end

  # @return [String, nil] the caption, if there is one.
  def caption
    @data['caption']
  end

  # @return [String] the URL of the image.
  def image_url
    @data['url']
  end

  # @return [Integer] the total amount of ratings.
  def total_ratings
    @data['rating']['total']
  end

  # @return [Float] the average rating.
  def average_rating
    @data['rating']['average']
  end

  # @return [Time] the time this meme was submitted.
  def timestamp
    Time.parse(@data['timestamp'])
  end

  # @return [User] the author of this meme.
  def author
    Memerator::User.new(@data['author'])
  end

  # @return [String] the URL to the meme
  def meme_url
    @data['permalink']
  end

  # @return [Array<Comment>] the comments
  def comments
    comments = JSON.parse(RestClient.get("https://api.memerator.me/v1/meme/#{memeid}/comments", Authorization: @token))
    comments.map { |comment_data| Memerator::Comment.new(comment_data) }
  end

  # Usually, the only people who can see disabled memes are Staff and the owners of the meme.
  # This will most likely always be false.
  # @return [true, false] the meme disabled status.
  def disabled?
    @data['disabled']
  end

  # @endgroup

  # @group Meme Modification Methods

  # Disables the meme, only works if you own the meme!
  # @raise [Memerator::Errors::NoPermission] if you don't have access to disable the meme
  # @raise [Memerator::Errors::NoChange] if the meme is already disabled
  # @raise [Memerator::Errors::InvalidToken] if your token is bad.
  # @return [true] when successful
  def disable!
    response = JSON.parse(RestClient.put("https://api.memerator.me/v1/meme/#{memeid}/disable", {}, Authorization: @token))
    @data['disabled'] = true
    response['success']
  rescue RestClient::NotFound
    raise Memerator::Errors::NoPermission, "your token doesn't grant you access to this meme"
  rescue RestClient::BadRequest
    raise Memerator::Errors::NoChange, "This Meme is already disabled!"
  rescue RestClient::Unauthorized
    raise Memerator::Errors::InvalidToken, "Your token expired!"
  end

  # Enable the meme, only works if you own the meme!
  # @raise [Memerator::Errors::NoPermission] if you don't have access to enable the meme
  # @raise [Memerator::Errors::NoChange] if the meme is already enabled
  # @raise [Memerator::Errors::InvalidToken] if your token is bad.
  # @return [true] when successful
  def enable!
    response = JSON.parse(RestClient.put("https://api.memerator.me/v1/meme/#{memeid}/enable", {}, Authorization: @token))
    @data['disabled'] = false
    response['success']
  rescue RestClient::NotFound
    raise Memerator::Errors::NoPermission, "your token doesn't grant you access to this meme"
  rescue RestClient::BadRequest
    raise Memerator::Errors::NoChange, "This Meme is already disabled!"
  rescue RestClient::Unauthorized
    raise Memerator::Errors::InvalidToken, "Your token expired!"
  end

  # Set the meme caption, only works if you own the meme!
  # @raise [Memerator::Errors::NoPermission] if you don't have access to modify the meme
  # @raise [Memerator::Errors::DisabledMeme] if the meme is disabled
  # @raise [Memerator::Errors::InvalidToken] if your token is bad.
  # @return [true] when successful
  def caption=(newcap)
    raise Memerator::Errors::DisabledMeme, "This meme is disabled and can't be interacted with" if disabled?

    response = JSON.parse(RestClient.put("https://api.memerator.me/v1/meme/#{memeid}/caption", {"caption" => newcap}.to_json, Authorization: @token, 'Content-Type': :json))
    @data['caption'] = newcap
    response['success']
  rescue RestClient::NotFound
    raise Memerator::Errors::NoPermission, "your token doesn't grant you access to this meme"
  rescue RestClient::Unauthorized
    raise Memerator::Errors::InvalidToken, "Your token expired!"
  end

  # Shorthand for #disable! and #enable!
  # @see #disable!
  # @see #enable!
  # @param dis [true, false] should we disable or enable
  # @raise [ArgumentError] if you didn't provide true or false
  # @return [true] if the meme was disabled
  # @return [false] if the meme was enabled
  def disabled=(dis)
    case dis
    when true
      disable!
    when false
      enable!
    else
      raise ArgumentError, "please provide true or false"
    end
  end

  # Rate a meme
  # This was a long running joke, in fact, until recently, you couldn't even rate a meme from the API! You're welcome.
  # @param rating [Integer] the rating to give this meme
  def rate(rating)
    raise Memerator::Errors::DisabledMeme, "This meme is disabled and can't be interacted with" if disabled?
    raise ArgumentError, "Your rating is bad mate!" if rating > 5 || rating < 1 || rating.to_i != rating

    response = JSON.parse(RestClient.post("https://api.memerator.me/v1/meme/#{memeid}/rate", {"rating" => rating}.to_json, Authorization: @token, 'Content-Type': :json))
    response['success']
  rescue RestClient::NotFound
    raise Memerator::Errors::NoPermission, "your token doesn't grant you access to this meme"
  rescue RestClient::Unauthorized
    raise Memerator::Errors::InvalidToken, "Your token expired!"
  end
end

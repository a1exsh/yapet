require 'digest/sha1'

module SecretCodes
  def make_secret_code(*args)
    args << self.object_id
    args << rand
    Digest::SHA1.hexdigest(args.shuffle.map(&:to_s).join('#'))
  end
end

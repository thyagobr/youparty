require 'google/api_client'
require 'oauth_util'

class VideosController < ApplicationController

  def callback
    if params[:code]
      youtube_scopes = ['https://www.googleapis.com/auth/youtube.readonly',
                          'https://www.googleapis.com/auth/yt-analytics.readonly']
      uri = URI("https://accounts.google.com/o/oauth2/token")
      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
      request.set_form_data({
        :code => params[:code],
        :client_id => "586140555385-m2lijkaqpbt7v7i3v7olg73i66cnrkfl.apps.googleusercontent.com",
        :client_secret => "fHQVb_cwRsx1IR6G6d1n0VJY",
        :redirect_uri => "http://localhost:3000/oauth/youtube/callback",
        :grant_type => "authorization_code"
        })
      res = http.request(request)
      puts res.body
      response_hash = JSON.parse(res.body)
      puts response_hash["access_token"]
      puts "##################################"
      user_credentials = Google::APIClient::ClientSecrets.load
      auhtorization = Signet::OAuth2::Client.new(
        :authorization_uri => user_credentials.authorization_uri,
        :token_credential_uri => user_credentials.token_credential_uri,
        :client_id => user_credentials.client_id,
        :client_secret => user_credentials.client_secret,
        :redirect_uri => user_credentials.redirect_uris.first,
        :scope => ['https://www.googleapis.com/auth/youtube', 'https://www.googleapis.com/auth/plus']
      )
      auhtorization.code = params[:code]
      auhtorization.fetch_access_token!
      client = Google::APIClient.new(
        :application_name => "Youparty",
        :application_version => "0.1",
        :authorization => auhtorization)
      youtube = client.discovered_api("youtube", "v3")
      opts = {}
      opts[:part] = 'id,snippet'
      search_response = client.execute!(
        :api_method => youtube.search.list,
        :parameters => opts
      )

      puts "Search response:"
      puts search_response
    end
    puts "END!!!!!"
    render nothing: true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_video
      @video = Video.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def video_params
      params[:video]
    end
  end

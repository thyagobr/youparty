require 'google/api_client'
require 'oauth_util'

class VideosController < ApplicationController
  before_action :set_video, only: [:show, :edit, :update, :destroy]

  # GET /videos
  # GET /videos.json
  def index
    @videos = Video.all
  end

  # GET /videos/1
  # GET /videos/1.json
  def show
  end

  # GET /videos/new
  def new
    @video = Video.new
  end

  # GET /videos/1/edit
  def edit
  end

  # POST /videos
  # POST /videos.json
  def create
    @video = Video.new(video_params)

    respond_to do |format|
      if @video.save
        format.html { redirect_to @video, notice: 'Video was successfully created.' }
        format.json { render :show, status: :created, location: @video }
      else
        format.html { render :new }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /videos/1
  # PATCH/PUT /videos/1.json
  def update
    respond_to do |format|
      if @video.update(video_params)
        format.html { redirect_to @video, notice: 'Video was successfully updated.' }
        format.json { render :show, status: :ok, location: @video }
      else
        format.html { render :edit }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /videos/1
  # DELETE /videos/1.json
  def destroy
    @video.destroy
    respond_to do |format|
      format.html { redirect_to videos_url, notice: 'Video was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

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
        :client_id => "586140555385-r9mihpkqjk7b7ggmjtgm8enaph770ltr.apps.googleusercontent.com",
        :client_secret => "YV-x_rUs84qOp7mnHHdpempe",
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
        :scope => 'https://www.googleapis.com/auth/youtube'
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
    render :nothing
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

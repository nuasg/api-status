class MainController < ApplicationController
  # @name_map = {
  #     "/terms" => "Terms",
  #     "/schools" => "Schools",
  #     "/subjects" => "Subjects",
  #     "/courses" => "Courses",
  #     "/courses/details" => "Course Details",
  #     "/instructors" => "Instructors",
  #     "/buildings" => "Buildings",
  #     "/rooms" => "Rooms",
  #     "/rooms/details" => "Room Details"
  # }
  #
  # @status_map = {
  #     "dark" => "Tests have not yet run.",
  #     "success" => "No issues are currently reported.",
  #     "warning" => "Minor issues reported.",
  #     "danger" => "Major issues reported."
  # }
  #
  # def self.status_map
  #   @status_map
  # end
  #
  # def self.name_map
  #   @name_map
  # end

  def index
    redis = Redis.new

    @results = TestResult.redis_get_all redis
    @results['/data/age'] = {
        category_name: 'Data Age',
        results: {
            worst: redis.hget('/data/age', 'result'),
            tests: [
                result: redis.hget('/data/age', 'result'),
                name: redis.hget('/data/age', 'string')
            ]
        }
    } unless redis.hget('/data/age', 'result').nil?

    last_run = redis.get 'last-run'

    current_time = DateTime.now
    last_run_time = DateTime.parse last_run unless last_run.nil?
    last_run_time ||= nil

    unless last_run_time.nil?
      if current_time > last_run_time
        @time_diff = TimeDifference.between(last_run_time, current_time).humanize
        @time_diff ||= '0 seconds'
        @time_diff.downcase!
      else
        @time_diff = '0 seconds'
      end
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to '/'
  end

  def run_update_job
    RunTestsJob.perform_later false

    flash[:notice] = 'Your request to run testing has been processed. Refresh this page in the next several seconds to see the latest results.'

    redirect_to '/'
  end

  def history
  end

  def admin
    redirect_to '/admin/login' and return if session[:user_id].nil?
    redirect_to '/' unless User.find(session[:user_id]).admin

    @notice = Notice.new
  end

  def notice_create
    notice = Notice.new

    notice.title = params[:notice][:title]
    notice.content = params[:notice][:content]

    notice.active = true
    notice.deactivated = nil

    notice.severity = params[:notice][:severity]

    notice.save

    redirect_to '/admin'
  end

  def view_results
    if session[:user_id].nil?
      session[:last] = request.fullpath

      redirect_to '/admin/login' and return
    end
    redirect_to '/' and return unless User.find(session[:user_id]).admin

    @result = TestResult.find_by(id: params[:id])

    not_found if @result.nil?

    @pretty = nil
    begin
      @pretty = JSON.pretty_generate(JSON.parse(@result.response))
    rescue JSON::JSONError
      #don't care
    end
  end

  def login

  end

  def notice_deactivate
    redirect_to '/admin/login' and return if session[:user_id].nil?
    redirect_to '/' and return unless User.find(session[:user_id]).admin

    notice = Notice.find(params[:id])
    notice.deactivate if !notice.nil? and notice.active

    redirect_to '/admin'
  end

  def notice_delete
    redirect_to '/admin/login' and return if session[:user_id].nil?
    redirect_to '/' unless User.find(session[:user_id]).admin

    notice = Notice.find(params[:id])
    notice.destroy unless notice.nil?

    redirect_to '/admin'
  end

  def authenticate
    @ldap = Net::LDAP.new(
        host: NetID::Auth::HOST,
        port: NetID::Auth::PORT,
        encryption: {
            method: :simple_tls,
            tls_options: OpenSSL::SSL::SSLContext::DEFAULT_PARAMS
        },
        auth: {
            method: :simple,
            username: NetID::Auth::USER,
            password: NetID::Auth::PASSWORD
        },
        base: 'dc=northwestern,dc=edu'
    )
    @ldap.host = NetID::Auth::HOST
    @ldap.port = NetID::Auth::PORT

    bound = false

    begin
      bound = @ldap.bind
    rescue
      flash[:warning] = 'Internal authentication error.'

      redirect_to '/admin/login' and return
    end

    unless bound
      flash[:warning] = 'Internal authentication error.'

      redirect_to '/admin/login' and return
    end

    filter = Net::LDAP::Filter.eq('uid', params['netid'].downcase)
    logger.info filter.inspect
    logger.info filter.to_s
    @res = @ldap.search(filter: filter)

    logger.info @res
    logger.info @ldap.get_operation_result
    if @res.nil? || @res.empty?
      flash[:warning] = 'Invalid NetID.'

      redirect_to '/admin/login' and return
    end

    @ldap.auth @res[0][:dn], params['password']

    begin
      bound = @ldap.bind
    rescue
      flash[:warning] = 'Internal authentication error.'

      redirect_to '/admin/login' and return
    end

    unless bound
      flash[:warning] = 'Invalid NetID password.'

      redirect_to '/admin/login' and return
    end

    exist = User.find_by(username: params['netid'].downcase)

    if exist.nil?
      user = User.new
      user.username = params['netid'].downcase
      user.email = @res[0][:mail][0] unless @res[0][:mail][0].nil?
      user.admin = User::ADMINS.include? user.username
      user.save

      session[:user_id] = user.id
    else
      if exist.email.nil? && !@res[0][:mail][0].nil?
        exist.email = @res[0][:mail][0]
        exist.save
      end

      session[:user_id] = exist.id
    end

    if !session[:last]
      redirect_to '/admin'
    else
      redirect_to session[:last]
    end
  end
end

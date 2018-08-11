module MainHelper
  def status(str)
    case str
    when 'dark'
      'Tests have not yet run.'
    when 'success'
      'No issues are currently reported.'
    when 'warning'
      'Minor issues reported.'
    when 'danger'
      'Major issues reported.'
    else
      'Unknown status.'
    end
  end

  def overall(results)
    return map(nil) if results.empty? || results.length == 1

    worst = 0

    results.each do |path, test_info|
      next if path == '/data/age'

      worst_category_str = test_info[:results][:worst]
      worst_category = TestResult.results[worst_category_str]

      worst = worst_category if worst_category > worst
    end

    map TestResult.results.key(worst)
  end

  def map(str)
    case str.to_s
    when 'pass'
      'success'
    when 'warn'
      'warning'
    when 'fail'
      'danger'
    else
      'dark'
    end
  end

  def active_notices
    Notice.where(active: true).order(created_at: :desc)
  end

  def all_notices_by_month
    Notice.order(created_at: :desc)
  end

  def user
    session[:user_id] ? User.find(session[:user_id]) : nil
  end
end

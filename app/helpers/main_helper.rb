module MainHelper
  def main_dot_type(tsts)
    a = "dark"

    tsts.each_value do |tst|
      case a
      when "dark"
        a = "success" if tst[:type] == "pass"
        a = "warning" if tst[:type] == "warn"
        a = "danger" if tst[:type] == "fail"
      when "success"
        a = "warning" if tst[:type] == "warn"
        a = "danger" if tst[:type] == "fail"
      when "warning"
        a = "danger" if tst[:type] == "fail"
      else
        break
      end
    end

    a
  end

  def individual_dot_type(tst)
    if tst[:type] == "pass"
      "success"
    elsif tst[:type] == "warn"
      "warning"
    elsif tst[:type] == "fail"
      "danger"
    else
      "dark"
    end
  end

  def overall_status(res)
    a = "dark"

    res.each_value do |tsts|
      z = main_dot_type tsts

      case a
      when "dark"
        a = z
      when "success"
        a = z if z == "danger" || z == "warning"
      when "warning"
        a = z if z == "danger"
      else
        break
      end
    end

    a
  end

  def active_notices
    Notice.where(active: true).order(created_at: :desc)
  end

  def all_notices_by_month
    Notice.order(created_at: :desc)
  end
end

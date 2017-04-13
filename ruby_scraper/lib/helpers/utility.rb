module Utility
  def query_string
		# [ "software developer", "frontend developer", "front end", "front-end developer", "mobile developer", "fullstack developer", "full stack", "full-stack developer", "backend developer", "back end", "back-end developer", "software engineer"
    # ]
    # ["[Mobile Developer]", "[Front-end Developer]", "[Back-end Developer]"]
    ["[Front-end Developer]", "[Back-end Developer]", "[Mobile Developer]", "[Mid-Level Developer]", "[Senior Developer]", ["Technical Product Manager"], "[DevOps Engineer]", "QA/Test Engineer", "[Engineering Manager]", "[VP Engineering]"]
  end

  def unallowed_params
    # " -senior -Lead -5+ -Director -Manager -Sr. -Sr -.Sr -Ph.D -PhD -specialist -experienced \
    #   -mid -seasoned -part-time -experienced -Instructor -Co-Founder \
		# 	-CTO -intern -internship -test -solution -scrum-master -ux-designer"
    # "-senior -Lead -5+ -Director -Manager -Sr. -Sr -.Sr -Ph.D -PhD -specialist -experienced \
    #   -mid -seasoned -part-time -experienced -Instructor -Co-Founder -CTO -intern -internship -test \
    #    -solution -scrum-master -ux -designer"
    "-5+, -Sr. -Sr -.Sr -Ph.D -PhD, -mid -seasoned"
  end

  def unallowed_title_params
    # "-senior -Lead -Director -Manager -specialist -experienced -part-time -experienced -Instructor -Co-Founder -CTO -intern -internship -test -solution -scrum-master -ux -designer -search -apply -jobAlerts -app.jobvite.com -error"
    "-apply -jobAlerts -search -error"
  end

  def youtube_exclusion
    " -youtube"
  end

  def permitted?(page_content)
    (unallowed_params.gsub(/(?<= )-/,"").downcase.split & page_content.downcase.split).empty?
  end

end

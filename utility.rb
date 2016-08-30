module Utility
  def query_string
		[ "software developer", "frontend developer", "front end", "front-end developer", "mobile developer", "fullstack developer", "full stack", "full-stack developer", "backend developer", "back end", "back-end developer", "software engineer"
    ]
  end

  def unallowed_params
    " -senior -Lead -5+ -Director -Manager -Sr -Ph.D -PhD -specialist -experienced \
      -mid -seasoned -part-time -Inc -Co -X-Team -experienced -Instructor -Co-Founder \
			-CTO -intern -internship -test -solution -scrum-master -ux-designer"
  end

  def youtube_exclusion
    " -youtube"
  end

  def permitted?(page_content)
    (unallowed_params.gsub(/(?<= )-/,"").downcase.split & page_content.downcase.split).empty?
  end

end

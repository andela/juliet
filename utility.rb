module Utility
  def query_string
    [ "software developer", "frontend developer", "fullstack developer", "backend developer", "software engineer",
      "ruby", "rails", "python", "django", "java", "android", "iOS", "php", "laravel"
    ]
  end

  def unallowed_params
    " -senior -.NET -c# -c++ -Lead -5+ -Director -Manager -Sr -Ph.D -PhD -specialist -experienced \
    -mid -seasoned -part-time -Inc -Co -X-Team -experienced -Instructor -Co-Founder -CTO"
  end

  def permitted?(page_content)
    (unallowed_params.gsub(/(?<= )-/,"").downcase.split & page_content.downcase.split).empty?
  end

end
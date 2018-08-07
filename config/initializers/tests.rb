module Tests
  # Test Definitions
  # "test path" => [
  #   {
  #     :name => "Test Name 1"
  #     :params => [
  #       ["parameter 1 name", "parameter 1 value"],
  #       ["parameter 2 name", "parameter 2 value"]
  #     ],
  #     :count => a number or "many",
  #     :expect => {
  #       :return_field_1 => Type,
  #       :return_field_2 => [Type1, Type2, nil]
  #     }
  #   },
  #   {
  #     :name => "Test Name 2"
  #     :params => [
  #       ["parameter 1 name", "parameter 1 value"],
  #       ["parameter 2 name", "parameter 2 value"]
  #     ],
  #     :count => a number or "many",
  #     :expect => {
  #       :return_field_1 => Type,
  #       :return_field_2 => [Type1, Type2, nil]
  #     }
  #   }
  # ]

  TESTS = {
      "/terms" => [
          {
              :name => "Terms",
              :params => [],
              :count => "many",
              :expect => {
                  :id => Integer,
                  :name => String,
                  :start_date => String,
                  :end_date => String
              }
          }
      ],
      "/schools" => [
          {
              :name => "Schools",
              :params => [],
              :count => "many",
              :expect => {
                  :symbol => String,
                  :name => String
              }
          }
      ],
      "/subjects" => [
          {
              :name => "Subjects",
              :params => [],
              :count => "many",
              :expect => {
                  :symbol => String,
                  :name => String
              }
          },
          {
              :name => "Subjects (by Term)",
              :params => [
                  ["term", 4720]
              ],
              :count => "many",
              :expect => {
                  :symbol => String,
                  :name => String
              }
          },
          {
              :name => "Subjects (by School)",
              :params => [
                  %w(school JOUR)
              ],
              :count => "many",
              :expect => {
                  :symbol => String,
                  :name => String
              }
          }
      ],
      "/courses" => [
          {
              :name => "Courses (by Instructor)",
              :params => [
                  ["instructor", 7136]
              ],
              :count => "many",
              :expect => {
                  :id => Integer,
                  :title => String,
                  :term => String,
                  :instructor => String,
                  :subject => String,
                  :catalog_num => String,
                  :section => String,
                  :room => [String, nil],
                  :meeting_days => String,
                  :start_time => String,
                  :end_time => String,
                  :seats => Integer,
                  :topic => [String, nil],
                  :component => String,
                  :class_num => Integer,
                  :course_id => Integer,
              }
          },
          {
              :name => "Courses (by ID)",
              :params => [
                  ["id", 150763]
              ],
              :count => 1,
              :expect => {
                  :id => Integer,
                  :title => String,
                  :term => String,
                  :instructor => String,
                  :subject => String,
                  :catalog_num => String,
                  :section => String,
                  :room => [String, nil],
                  :meeting_days => String,
                  :start_time => String,
                  :end_time => String,
                  :seats => Integer,
                  :topic => [String, nil],
                  :component => String,
                  :class_num => Integer,
                  :course_id => Integer,
              }
          },
          {
              :name => "Courses (by IDs)",
              :params => [
                  ["id", 150763],
                  ["id", 165749]
              ],
              :count => 2,
              :expect => {
                  :id => Integer,
                  :title => String,
                  :term => String,
                  :instructor => String,
                  :subject => String,
                  :catalog_num => String,
                  :section => String,
                  :room => [String, nil],
                  :meeting_days => String,
                  :start_time => String,
                  :end_time => String,
                  :seats => Integer,
                  :topic => [String, nil],
                  :component => String,
                  :class_num => Integer,
                  :course_id => Integer,
              }
          },
          {
              :name => "Courses (by Term and Subject)",
              :params => [
                  ["term", 4720],
                  %w(subject MATH)
              ],
              :count => "many",
              :expect => {
                  :id => Integer,
                  :title => String,
                  :term => String,
                  :instructor => String,
                  :subject => String,
                  :catalog_num => String,
                  :section => String,
                  :room => [String, nil],
                  :meeting_days => String,
                  :start_time => String,
                  :end_time => String,
                  :seats => Integer,
                  :topic => [String, nil],
                  :component => String,
                  :class_num => Integer,
                  :course_id => Integer,
              }
          },
          {
              :name => "Courses (by Term and Room)",
              :params => [
                  ["term", 4720],
                  ["room", 184]
              ],
              :count => "many",
              :expect => {
                  :id => Integer,
                  :title => String,
                  :term => String,
                  :instructor => String,
                  :subject => String,
                  :catalog_num => String,
                  :section => String,
                  :room => [String, nil],
                  :meeting_days => String,
                  :start_time => String,
                  :end_time => String,
                  :seats => Integer,
                  :topic => [String, nil],
                  :component => String,
                  :class_num => Integer,
                  :course_id => Integer,
              }
          }
      ],
      "/courses/details" => [
          {
              :name => "Course Details (by Instructor)",
              :params => [
                  ["instructor", 7136]
              ],
              :count => "many",
              :expect => {
                  :id => Integer,
                  :title => String,
                  :term => String,
                  :school => String,
                  :instructor => Hash,
                  :subject => String,
                  :catalog_num => String,
                  :section => String,
                  :room => [Hash, nil],
                  :meeting_days => String,
                  :start_time => String,
                  :end_time => String,
                  :seats => Integer,
                  :start_date => String,
                  :end_date => String,
                  :topic => [String, nil],
                  :component => String,
                  :class_num => Integer,
                  :course_id => Integer,
                  :overview => [String, nil],
                  :attributes => [String, nil],
                  :requirements => [String, nil],
                  :course_descriptions => Array,
                  :course_components => Array,
              }
          },
          {
              :name => "Course Details (by ID)",
              :params => [
                  ["id", 150763]
              ],
              :count => 1,
              :expect => {
                  :id => Integer,
                  :title => String,
                  :term => String,
                  :instructor => Hash,
                  :subject => String,
                  :catalog_num => String,
                  :section => String,
                  :room => [Hash, nil],
                  :meeting_days => String,
                  :start_time => String,
                  :end_time => String,
                  :seats => Integer,
                  :start_date => String,
                  :end_date => String,
                  :topic => [String, nil],
                  :component => String,
                  :class_num => Integer,
                  :course_id => Integer,
                  :overview => [String, nil],
                  :attributes => [String, nil],
                  :requirements => [String, nil],
                  :course_descriptions => Array,
                  :course_components => Array,
                  :school => String
              }
          },
          {
              :name => "Course Details (by IDs)",
              :params => [
                  ["id", 150763],
                  ["id", 165749]
              ],
              :count => 2,
              :expect => {
                  :id => Integer,
                  :title => String,
                  :term => String,
                  :instructor => Hash,
                  :subject => String,
                  :catalog_num => String,
                  :section => String,
                  :room => [Hash, nil],
                  :meeting_days => String,
                  :start_time => String,
                  :end_time => String,
                  :seats => Integer,
                  :start_date => String,
                  :end_date => String,
                  :topic => [String, nil],
                  :component => String,
                  :class_num => Integer,
                  :course_id => Integer,
                  :overview => [String, nil],
                  :attributes => [String, nil],
                  :requirements => [String, nil],
                  :course_descriptions => Array,
                  :course_components => Array,
                  :school => String
              }
          },
          {
              :name => "Course Details (by Term and Subject)",
              :params => [
                  ["term", 4720],
                  %w(subject MATH)
              ],
              :count => "many",
              :expect => {
                  :id => Integer,
                  :title => String,
                  :term => String,
                  :instructor => Hash,
                  :subject => String,
                  :catalog_num => String,
                  :section => String,
                  :room => [Hash, nil],
                  :meeting_days => String,
                  :start_time => String,
                  :end_time => String,
                  :seats => Integer,
                  :start_date => String,
                  :end_date => String,
                  :topic => [String, nil],
                  :component => String,
                  :class_num => Integer,
                  :course_id => Integer,
                  :overview => [String, nil],
                  :attributes => [String, nil],
                  :requirements => [String, nil],
                  :course_descriptions => Array,
                  :course_components => Array,
                  :school => String
              }
          },
          {
              :name => "Course Details (by Term and Room)",
              :params => [
                  ["term", 4720],
                  ["room", 184]
              ],
              :count => "many",
              :expect => {
                  :id => Integer,
                  :title => String,
                  :term => String,
                  :instructor => Hash,
                  :subject => String,
                  :catalog_num => String,
                  :section => String,
                  :room => [Hash, nil],
                  :meeting_days => String,
                  :start_time => String,
                  :end_time => String,
                  :seats => Integer,
                  :start_date => String,
                  :end_date => String,
                  :topic => [String, nil],
                  :component => String,
                  :class_num => Integer,
                  :course_id => Integer,
                  :overview => [String, nil],
                  :attributes => [String, nil],
                  :requirements => [String, nil],
                  :course_descriptions => Array,
                  :course_components => Array,
                  :school => String
              }
          }
      ],
      "/instructors" => [
          {
              :name => "Instructors",
              :params => [
                  %w(subject JOUR)
              ],
              :count => "many",
              :expect => {
                  :id => Integer,
                  :name => String,
                  :bio => [String, nil],
                  :address => nil,
                  :phone => nil,
                  :office_hours => nil,
                  :subjects => Array
              }
          }
      ],
      "/buildings" => [
          {
              :name => "Buildings",
              :params => [],
              :count => "many",
              :expect => {
                  :id => Integer,
                  :name => String,
                  :lat => [Float, nil],
                  :lon => [Float, nil],
                  :nu_maps_link => [String, nil]
              }
          }
      ],
      "/rooms" => [
          {
              :name => "Rooms (by Building)",
              :params => [
                  ["building", 60]
              ],
              :count => "many",
              :expect => {
                  :id => Integer,
                  :building_id => Integer,
                  :name => String
              }
          },
          {
              :name => "Rooms (by ID)",
              :params => [
                  ["id", 178]
              ],
              :count => 1,
              :expect => {
                  :id => Integer,
                  :building_id => Integer,
                  :name => String
              }
          },
          {
              :name => "Rooms (by IDs)",
              :params => [
                  ["id", 178],
                  ["id", 180]
              ],
              :count => 2,
              :expect => {
                  :id => Integer,
                  :building_id => Integer,
                  :name => String
              }
          }
      ],
      "/rooms/details" => [
          {
              :name => "Room Details (by Building)",
              :params => [
                  ["building", 60]
              ],
              :count => "many",
              :expect => {
                  :id => Integer,
                  :building => Hash,
                  :name => String
              }
          },
          {
              :name => "Room Details (by ID)",
              :params => [
                  ["id", 178]
              ],
              :count => 1,
              :expect => {
                  :id => Integer,
                  :building => Hash,
                  :name => String
              }
          },
          {
              :name => "Room Details (by IDs)",
              :params => [
                  ["id", 178],
                  ["id", 180]
              ],
              :count => 2,
              :expect => {
                  :id => Integer,
                  :building => Hash,
                  :name => String
              }
          }
      ]
  }
end
Feature: Manage Groups
  In order to encourage Democrats to get involved
  The Wake County Democratic Party
  Wants to support groups of Democrats
  
  Scenario: Register new group
    Given I am on the new group page
    When I fill in "Name" with "WCDP Executive Board"
    And I fill in "Description" with "The Executive Board of the WCDP"
    And I check "Public"
    And I press "Create"
    Then I should see "WCDP Executive Board"
    And I should see "The Executive Board of the WCDP"
    And I should see "Public"

  Scenario: Delete group
    Given the following groups:
      |name|description|public|avatar_id|
      |name 1|description 1|false|1|
      |name 2|description 2|true|2|
      |name 3|description 3|false|3|
      |name 4|description 4|true|4|
    When I delete the 3rd group
    Then I should see the following groups:
      |Name|Description|Public|Avatar|
      |name 1|description 1|false|1|
      |name 2|description 2|true|2|
      |name 4|description 4|true|4|

  Scenario: View groups as a visitor
  
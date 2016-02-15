Feature: Periods and states

#Final - will not change anymore
  @periods_and_states @browser
  Scenario: Creating a budget period
    Given I am Hans Ueli
    And there does not exist any budget period yet
    When I navigate to the budget periods
    Then there is an empty budget period line for creating a new one
    When I fill in the name
    And I fill in the start date of the inspection period
    And I fill in the end date of the budget period
    And I click on save
    Then I see a success message

#Final - will not change anymore
  @periods_and_states @browser
  Scenario: Deleting a Period
    Given I am Hans Ueli
    And a budget period without any requests exists
    When I navigate to the budget periods
    And I click on 'delete' on the line for this budget period
    Then this budget period disappears from the list
    And this budget period was deleted from the database

#Final - will not change anymore
  @periods_and_states @browser
  Scenario: Editing a Budget Period
    Given I am Hans Ueli
    And budget periods exist
    And I navigate to the budget periods
    When I choose a budget period to edit
    And I change the name of the budget period
    And I change the inspection start date of the budget period
    And I change the end date of the budget period
    And I click on save
    Then I see a success message
    And the budget period line was updated successfully
    And the data for the budget period was updated successfully in the database

  @periods_and_states @browser
  Scenario: Budget Period End Date earlyer than Inspection Start Date
    Given I am Hans Ueli
    And budget periods exist
    And I navigate to the budget periods
    When I edit a budget period
    And I set the end date of the budget period earlyer than the inspection start date
    And I click on save
    Then I see an error message
    And the data for the budget period was not saved to the database

  @periods_and_states @browser
  Scenario: Mandatory Fields of a Budget Period
    Given I am Hans Ueli
    When I navigate to the budget periods
    And I add a new line
    Then I see which fields are mandatory
    When I have not filled the mandatory fields
    Then I can not save the data

  @periods_and_states @browser
  Scenario: Delete an unsaved Budget Period
    Given I am Hans Ueli
    When I navigate to the budget periods
    And I add a new line
    When I have not saved the data yet
    Then I can delete the line

  @periods_and_states @browser
  Scenario: Show Totals of each Budget Period
    Given I am Hans Ueli
    And budget periods exist
    When I navigate to the budget periods
    Then for every budget period I see the total of all requested articles with status "New"
    And for every budget period I see the total of the order amount of all requests with status "Approved"

#Final - will not change anymore
  @periods_and_states @browser
  Scenario: State "New" - Request Date before Inspection Date
    Given I am Roger
    Given a request exists
    Given the current date is before the inspection date
    Then I see the state "New"

#Final - will not change anymore
  @periods_and_states @browser
  Scenario: State "Inspection" - Current Date between Inspection Date and Budget Period End Date
    Given I am Roger
    Given a request exists
    When the current date is between the inspection date and the budget period end date
    Then I see the state "In inspection"
    And I can not modify the request

#Final - will not change anymore
    @periods_and_states @browser
    Scenario: Overview of Budget Periods
      Given I am Hans Ueli
      Given budget periods exist
      And I navigate to the budget periods
      Then the budget periods are sorted from 0-10 and a-z
  #??# total required costs instead?
  #    And the amount of requests per budget period is shown

#Final - will not change anymore
  @periods_and_states @browser
  Scenario Outline: State "In inspection", "Approved", "Denied" "Partially approved" for requester when budget period has ended
    Given I am Roger
    Given a request exists
    When the approved quantity is <quantity>
    And the current date is after the budget period end date
    Then I see the state "<state>"
    Examples:
      | quantity                                         | state              |
      | empty                                            | New                |
      | equal to the requested quantity                  | Approved           |
      | smaller than the requested quantity, not equal 0 | Partially approved |
      | equal 0                                          | Denied             |

#Final - will not change anymore
  @periods_and_states @browser
  Scenario Outline: State "New", "Approved", "Denied" "Partially approved" for inspector
    Given I am Barbara
    Given a request exists
    When the approved quantity is <quantity>
    Then I see the state "<state>"
    Examples:
      | quantity                                         | state              |
      | empty                                            | New                |
      | equal to the requested quantity                  | Approved           |
      | smaller than the requested quantity, not equal 0 | Partially approved |
      | equal 0                                          | Denied             |

#Final - will not change anymore
  @periods_and_states @browser
  Scenario Outline: No Modification or Deletion after Budget End Period date
    Given I am <username>
    Given a request exists
    When the budget period has ended
    Then I can not create any request for the budget period which has ended
    And I can not modify any request for the budget period which has ended
    And I can not delete any requests for the budget period which has ended
    And I can not move a request to a budget period which has ended
    And I can not move a request of a budget period which has ended to another procurement group
    Examples:
      | username  |
      | Barbara   |
      | Hans Ueli |
      | Roger     |

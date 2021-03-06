require 'spec_helper'

describe Deliverable do

  it 'can be created' do
    lambda {
      FactoryGirl.create(:deliverable)
    }.should change(Deliverable, :count).by(1)
  end

  context "is valid" do
    before(:each) do
      @deliverable = FactoryGirl.build(:deliverable)
    end
  end

  context "is not valid" do

    [:course, :assignment, :creator].each do |attr|
      it "without #{attr}" do
        subject.should_not be_valid
        subject.errors[attr].should_not be_empty
      end
    end

    context "when a duplicate deliverable for the same course, assignment and owner" do
      [:team_deliverable, :individual_deliverable].each do |symbol|
        it "for a team/individual deliverable" do
          original = FactoryGirl.build(symbol)
          original.stub(:update_team)
          original.save
          duplicate = Deliverable.new()
          duplicate.stub(:update_team)
          duplicate.creator_id = original.creator_id
          duplicate.assignment = original.assignment
          duplicate.team_id = original.team_id
          duplicate.should_not be_valid
        end
      end
    end
  end

  it "should return team name for a team deliverable" do
    deliverable = FactoryGirl.build(:team_deliverable)
    deliverable.stub(:update_team)
    deliverable.save
    deliverable.owner_name.should be_equal(deliverable.team.name)
  end

    it "should return person name for a individual deliverable" do
    deliverable = FactoryGirl.create(:individual_deliverable)
    deliverable.owner_name.should be_equal(deliverable.creator.human_name)
  end

  it "should return team email for a team deliverable" do
    deliverable = FactoryGirl.build(:team_deliverable)
    deliverable.stub(:update_team)
    deliverable.save
    deliverable.owner_email.should be_equal(deliverable.team.email)
  end

  it "should return person email for a individual deliverable" do
    deliverable = FactoryGirl.create(:individual_deliverable)
    deliverable.owner_email.should be_equal(deliverable.creator.email)
  end

  context "has_feedback?" do
  it "returns false when there is no feedback" do
    subject.has_feedback?.should be_false

#!(self.feedback_comment.nil? or self.feedback_comment == "") or !self.feedback_file_name.nil?
  end

  it "returns true when there is a comment" do
    subject.feedback_comment = "Great job team!"
    subject.has_feedback?.should be_true
  end

  it "returns true when there is a file" do
    subject.feedback_file_name = "/somewhere_on_s3/somewhere_over_the_rainbow/amazing_feedback.txt"
    subject.has_feedback?.should be_true
  end


  end

  context "for a team" do
    before(:each) do
      @deliverable = FactoryGirl.build(:team_deliverable)
      @team_member = @deliverable.team.members[0]
    end

    it "is not editable by any random student" do
      @deliverable.editable?(FactoryGirl.create(:student_sally, :email=>"student.sally2@sv.cmu.edu", :webiso_account =>"ss2@andrew.cmu.edu")).should be_false
    end

    it "is editable by staff or admin" do
      @deliverable.editable?(FactoryGirl.create(:faculty_frank)).should be_true
     end

    it "is editable by a team member" do
      @deliverable.editable?(@team_member).should be_true
    end
  end

  context "for an individual deliverable" do
    before(:each) do
      @deliverable = FactoryGirl.build(:individual_deliverable)
      @individual = @deliverable.creator
    end

    it "is not editable by any random student" do
      @deliverable.editable?(FactoryGirl.create(:student_sally, :email=>"student.sally2@sv.cmu.edu", :webiso_account =>"ss2@andrew.cmu.edu")).should be_false
    end

    it "is editable by staff or admin" do
      @deliverable.editable?(FactoryGirl.create(:faculty_frank)).should be_true
     end

    it "is editable by its owner" do
      @deliverable.editable?(@individual).should be_true
    end
  end

  context "for an individual deliverable's grading status" do
    before(:each) do
      @deliverable = FactoryGirl.build(:individual_deliverable)
    end

    it "is visible if the grade is published" do
      grade = FactoryGirl.build(:grade_visible)
      Grade.stub(:get_grade).with(@deliverable.assignment.id, @deliverable.creator.id).and_return(grade)
      @deliverable.is_visible_to_student?.should be_true
    end

    it "is invisible if the grade is not published" do
      grade = FactoryGirl.build(:grade_invisible)
      Grade.stub(:get_grade).with(@deliverable.assignment.id, @deliverable.creator.id).and_return(grade)
      @deliverable.is_visible_to_student?.should be_false
    end

    it "is invisible if it is not graded" do
      Grade.stub(:get_grade).with(@deliverable.assignment.id, @deliverable.creator.id).and_return(nil)
      @deliverable.is_visible_to_student?.should be_false
    end
    
    it "is graded if grade is given and published" do
      grade = FactoryGirl.build(:grade_visible)
      Grade.stub(:get_grade).with(@deliverable.assignment.id, @deliverable.creator.id).and_return(grade)
      @deliverable.get_grade_status.should eq(:graded)
    end
    
    it "is ungraded if grade is not given" do
      Grade.stub(:get_grade).with(@deliverable.assignment.id, @deliverable.creator.id).and_return(nil)
      @deliverable.get_grade_status.should eq(:ungraded)
    end
    
    it "is drafted if grade is given but not published" do
      grade = FactoryGirl.build(:grade_invisible)
      Grade.stub(:get_grade).with(@deliverable.assignment.id, @deliverable.creator.id).and_return(grade)
      @deliverable.get_grade_status.should eq(:drafted)
    end
  end

  context "for a team deliverable's grading status" do
    before(:each) do
      @deliverable = FactoryGirl.build(:team_deliverable)
    end

    it "is graded if all of members' grades are given and published" do
      @deliverable.team.members.each do | member |
        grade = FactoryGirl.build(:grade_visible, :student_id => member.id)
        Grade.stub(:get_grade).with(@deliverable.assignment.id, member.id).and_return(grade)
      end
      @deliverable.get_grade_status.should eq(:graded)
    end
    
    it "is drafted if any of the member's grade is given but not published" do
      grade = FactoryGirl.build(:grade_invisible)
      @deliverable.team.members.each do | member |
        grade = FactoryGirl.build(:grade_invisible, :student_id => member.id)
        Grade.stub(:get_grade).with(@deliverable.assignment.id, member.id).and_return(grade)
      end
      @deliverable.get_grade_status.should eq(:drafted)
    end
    
    it "is ungraded if any of the member's grade is not given" do
      @deliverable.team.members.each do | member |
        Grade.stub(:get_grade).with(@deliverable.assignment.id, member.id).and_return(nil)
      end
      @deliverable.get_grade_status.should eq(:ungraded)
    end
  end
end



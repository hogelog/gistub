require 'spec_helper'

describe Gist do

  it 'is available' do
    gist = create(:gist)
    gist.user.should_not be_nil
  end

  it 'returns latest_history' do
    history1 = create(:gist_history)
    history2 = create(:gist_history, :gist => history1.gist)

    gist = history1.gist
    gist.latest_history.should eq(history2)
  end

  it 'returns forks' do
    gist = create(:gist)
    fork1 = create(:gist, :source_gist => gist)
    fork2 = create(:gist, :source_gist => gist)

    gist.forks.size.should eq(2)
    gist.forks.map { |f| f.id }.should eq([fork2.id, fork1.id])
  end

  it 'finds already forked gist' do
    user = create(:user)
    gist = create(:gist)

    Gist.find_already_forked(gist.id, user.id).should be_nil

    forked = create(:gist, :source_gist => gist, :user => user)
    Gist.find_already_forked(gist.id, user.id).id.should eq(forked.id)
  end

  it 'returns my gists' do
    user = create(:user)
    create(:gist, :user => user)
    create(:gist, :user => user)
    create(:gist, :user => user)

    mine = Gist.find_my_recent_gists(user.id)
    mine.size.should eq(3)
  end

  it 'find my gist even if private' do
    user = create(:user)

    public_gist = create(:gist, :is_public => true, :user => user)
    found = Gist.find_my_gist_even_if_private(public_gist.id, user.id)
    found.should_not be_nil

    private_gist = create(:gist, :is_public => false, :user => user)
    found = Gist.find_my_gist_even_if_private(private_gist.id, user.id)
    found.should_not be_nil

    other_user = create(:user)
    not_found = Gist.find_my_gist_even_if_private(private_gist.id, other_user.id)
    not_found.should be_nil
  end

  it 'find commentable gist' do
    user = create(:user)

    public_gist = create(:gist)
    found = Gist.find_commentable_gist(public_gist.id, user.id)
    found.should_not be_nil

    my_private_gist = create(:gist, :is_public => false, :user => user)
    found = Gist.find_commentable_gist(my_private_gist.id, user.id)
    found.should_not be_nil

    other_user = create(:user)
    private_gist = create(:gist, :is_public => false, :user => other_user)
    not_found = Gist.find_commentable_gist(private_gist.id, user.id)
    not_found.should be_nil
  end

end

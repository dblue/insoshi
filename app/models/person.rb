# == Schema Information
# Schema version: 20080916002106
#
# Table name: people
#
#  id                         :integer(4)      not null, primary key
#  email                      :string(255)     
#  name                       :string(255)     
#  remember_token             :string(255)     
#  crypted_password           :string(255)     
#  description                :text            
#  remember_token_expires_at  :datetime        
#  last_contacted_at          :datetime        
#  last_sign_in_at          :datetime        
#  forum_posts_count          :integer(4)      default(0), not null
#  blog_post_comments_count   :integer(4)      default(0), not null
#  wall_comments_count        :integer(4)      default(0), not null
#  created_at                 :datetime        
#  updated_at                 :datetime        
#  admin                      :boolean(1)      not null
#  deactivated                :boolean(1)      not null
#  connection_notifications   :boolean(1)      default(TRUE)
#  message_notifications      :boolean(1)      default(TRUE)
#  wall_comment_notifications :boolean(1)      default(TRUE)
#  blog_comment_notifications :boolean(1)      default(TRUE)
#  email_verified             :boolean(1)      
#  avatar_id                  :integer(4)      
#  identity_url               :string(255)     
#

class Person < ActiveRecord::Base
  include ActivityLogger
  extend PreferencesHelper

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :name, :description, :connection_notifications,
                  :message_notifications, :wall_comment_notifications,
                  :blog_comment_notifications, :verify_password
                  
  attr_accessor :sorted_photos, :verify_password

  # Indexed fields for Sphinx
  #is_indexed :fields => [ 'name', 'description', 'deactivated',
  #                        'email_verified'],
  #           :conditions => "deactivated = false AND (email_verified IS NULL OR email_verified = true)"
  define_index do
    indexes name, description, deactivated, email_verified
    where "deactivated = false AND (email_verified IS NULL or email_verified = true)"
  end
  MAX_EMAIL = MAX_PASSWORD = 40
  MAX_NAME = 40
  MAX_DESCRIPTION = 5000
  EMAIL_REGEX = /\A[A-Z0-9\._%+-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}\z/i
  TRASH_TIME_AGO = 1.month.ago
  SEARCH_LIMIT = 20
  SEARCH_PER_PAGE = 8
  MESSAGES_PER_PAGE = 5
  NUM_RECENT_MESSAGES = 4
  NUM_WALL_COMMENTS = 10
  NUM_RECENT = 8
  FEED_SIZE = 10
  MAX_DEFAULT_CONTACTS = 12
  TIME_AGO_FOR_MOSTLY_ACTIVE = 1.month.ago
  # These constants should be methods, but I couldn't figure out how to use
  # methods in the has_many associations.  I hope you can do better.
  ACCEPTED_AND_ACTIVE =  [%(status = ? AND
                            deactivated = ? AND
                            (email_verified IS NULL OR email_verified = ?)),
                          Connection::ACCEPTED, false, true]
  REQUESTED_AND_ACTIVE =  [%(status = ? AND
                            deactivated = ? AND
                            (email_verified IS NULL OR email_verified = ?)),
                          Connection::REQUESTED, false, true]

  has_one :blog
  has_many :email_verifications
  has_many :comments, :as => :commentable, :order => 'created_at DESC',
                      :limit => NUM_WALL_COMMENTS
  has_many :connections
  has_many :contacts, :through => :connections,
                      :conditions => ACCEPTED_AND_ACTIVE,
                      :order => 'people.created_at DESC'
  has_many :photos, :dependent => :destroy, :order => 'created_at'
  has_many :requested_contacts, :through => :connections,
           :source => :contact,
           :conditions => REQUESTED_AND_ACTIVE
  with_options :class_name => "Message", :dependent => :destroy,
               :order => 'created_at DESC' do |person|
    person.has_many :_sent_messages, :foreign_key => "sender_id",
                    :conditions => "sender_deleted_at IS NULL"
    person.has_many :_received_messages, :foreign_key => "recipient_id",
                    :conditions => "recipient_deleted_at IS NULL"
  end
  has_many :feeds
  has_many :activities, :through => :feeds, :order => 'activities.created_at DESC',
                                            :limit => FEED_SIZE,
                                            :conditions => ["people.deactivated = ?", false],
                                            :include => :person

  has_many :page_views, :order => 'created_at DESC'
  has_many :galleries
  has_many :events
  has_many :event_attendees
  has_many :attendee_events, :through => :event_attendees, :source => :event

  validates_presence_of     :email, :name
  validates_length_of       :email, :within => 6..MAX_EMAIL
  validates_length_of       :name,  :maximum => MAX_NAME
  validates_length_of       :description, :maximum => MAX_DESCRIPTION
  validates_format_of       :email,
                            :with => EMAIL_REGEX,
                            :message => "must be a valid email address"
  validates_uniqueness_of   :email

  before_create :create_blog, :check_config_for_deactivation
  before_validation :prepare_email, :handle_nil_description
  after_create :connect_to_admin

  before_update :set_old_description
  after_update :log_activity_description_changed
  before_destroy :destroy_activities, :destroy_feeds

  scope :active, lambda{ where(conditions_for_active) }
  scope :mostly_active, lambda {where(conditions_for_mostly_active)}

  class << self

    # Return the paginated active users.
    # def active(page = 1)
    #   paginate(:all, :page => page,
    #                  :per_page => RASTER_PER_PAGE,
    #                  :conditions => conditions_for_active)
    # end
    
    # Return the people who are 'mostly' active.
    # People are mostly active if they have logged in recently enough.
    # def mostly_active(page = 1)
    #   paginate(:all, :page => page,
    #                  :per_page => RASTER_PER_PAGE,
    #                  :conditions => conditions_for_mostly_active,
    #                  :order => "created_at DESC")
    # end

    #TODO: convert these 3 to scopes after testing works.
    # Return *all* the active users.
    def all_active
      self.where(conditions_for_active)
    end
    
    def find_recent
      self.order('created_at DESC').limit(NUM_RECENT).includes(:photos)
    end

    # Return the first admin created.
    # We suggest using this admin as the primary administrative contact.
    def find_first_admin
      self.where( :admin => true ).order(:created_at).first
    end
  end

  # Params for use in urls.
  # Profile urls have the form '/people/1-michael-hartl'.
  # This works automagically because Person.find(params[:id]) implicitly
  # converts params[:id] into an int, and in Ruby
  # '1-michael-hartl'.to_i == 1
  def to_param
    "#{id}-#{name.to_safe_uri}"
  end

  ## Feeds

  # Return a person-specific activity feed.
  def feed
    len = activities.length
    if len < FEED_SIZE
      # Mix in some global activities for smaller feeds.
      global = Activity.global_feed[0...(Activity::GLOBAL_FEED_SIZE-len)]
      (activities + global).uniq.sort_by { |a| a.created_at }.reverse
    else
      activities
    end
  end

  def recent_activity
    Activity.find_all_by_person_id(self, :order => 'created_at DESC',
                                         :limit => FEED_SIZE)
  end

  ## For the home page...

  # Return some contacts for the home page.
  def some_contacts
    contacts[(0...MAX_DEFAULT_CONTACTS)]
  end

  # Contact links for the contact image raster.
  def requested_contact_links
    requested_contacts.map do |p|
      conn = Connection.conn(self, p)
      edit_connection_path(conn)
    end
  end

  ## Message methods
  
  #TODO: Replace with scopes.  Get paginate out of the models.
  def received_messages(page = 1)
    _received_messages.paginate(:page => page, :per_page => MESSAGES_PER_PAGE)
  end

  def sent_messages(page = 1)
    _sent_messages.paginate(:page => page, :per_page => MESSAGES_PER_PAGE)
  end

  def trashed_messages(page = 1)
    conditions = [%((sender_id = :person AND sender_deleted_at > :t) OR
                    (recipient_id = :person AND recipient_deleted_at > :t)),
                  { :person => id, :t => TRASH_TIME_AGO }]
    order = 'created_at DESC'
    trashed = Message.where(conditions).order(order).paginate( :page => page, :per_page => MESSAGES_PER_PAGE )
  end

  def recent_messages
    Message.find(:all,
                 :conditions => [%(recipient_id = ? AND
                                   recipient_deleted_at IS NULL), id],
                 :order => "created_at DESC",
                 :limit => NUM_RECENT_MESSAGES)
  end

  ## Forum helpers
  def forum_posts
    Topic.find(:all,
               :conditions => [%(forum_id =? AND
                                 person_id = ?), 1, id])
  end

  def has_unread_messages?
    sql = %(recipient_id = :id
            AND sender_id != :id
            AND recipient_deleted_at IS NOT NULL
            AND recipient_read_at IS NULL)
    conditions = [sql, { :id => id }]
    Message.count(:all, :conditions => conditions) > 0
  end

  ## Photo helpers
  
  def photo
    # This should only have one entry, but use 'first' to be paranoid.
    photos.find_all_by_avatar(true).first
  end

  # Return all the photos other than the primary one
  def other_photos
    photos.length > 1 ? photos - [photo] : []
  end

  def main_photo
    photo.nil? ? "default.png" : photo.public_filename
  end

  def thumbnail
    photo.nil? ? "default_thumbnail.png" : photo.public_filename(:thumbnail)
  end

  def icon
    photo.nil? ? "default_icon.png" : photo.public_filename(:icon)
  end

  def bounded_icon
    photo.nil? ? "default_icon.png" : photo.public_filename(:bounded_icon)
  end

  # Return the photos ordered by primary first, then by created_at.
  # They are already ordered by created_at as per the has_many association.
  def sorted_photos
    # The call to partition ensures that the primary photo comes first.
    # photos.partition(&:primary) => [[primary], [other one, another one]]
    # flatten yields [primary, other one, another one]
    @sorted_photos ||= photos.partition(&:primary).flatten
  end

  # Return true if the person is the last remaining active admin.
  def last_admin?
    num_admins = Person.count(:conditions => ["admin = ? AND deactivated = ?",
                                              true, false])
    admin? and num_admins == 1
  end

  def active?
    if Person.global_prefs.email_verifications?
      not deactivated? and email_verified?
    else
      not deactivated?
    end
  end

  # Return the common connections with the given person.
  def common_contacts_with(other_person, options = {})
    # I tried to do this in SQL for efficiency, but failed miserably.
    # Horrifyingly, MySQL lacks support for the INTERSECT keyword.
    (contacts & other_person.contacts).paginate(options)
  end
  
  protected

    ## Callbacks

    # Prepare email for database insertion.
    def prepare_email
      self.email = email.downcase.strip if email
    end

    # Handle the case of a nil description.
    # Some databases (e.g., MySQL) don't allow default values for text fields.
    # By default, "blank" fields are really nil, which breaks certain
    # validations; e.g., nil.length raises an exception, which breaks
    # validates_length_of.  Fix this by setting the description to the empty
    # string if it's nil.
    def handle_nil_description
      self.description = "" if description.nil?
    end

    def check_config_for_deactivation
      if Person.global_prefs.whitelist?
        self.deactivated = true
      end
    end

    def set_old_description
      @old_description = Person.find(self).description
    end

    def log_activity_description_changed
      unless @old_description == description or description.blank?
        add_activities(:item => self, :person => self)
      end
    end
    
    # Clear out all activities associated with this person.
    def destroy_activities
      self.activities.all.each {|a| a.destroy}
    end
    
    def destroy_feeds
      self.feeds.all.each {|f| f.destroy}
    end

    # Connect new users to "Tom".
    def connect_to_admin
      # Find the first admin created.
      # The uninitiated should Google "tom myspace".
      tom = Person.find_first_admin
      unless tom.nil? or tom == self
        Connection.connect(self, tom)
      end
    end

    class << self
    
      # Return the conditions for a user to be active.
      def conditions_for_active
        [%(deactivated = ? AND 
           (email_verified IS NULL OR email_verified = ?)),
         false, true]
      end
      
      # Return the conditions for a user to be 'mostly' active.
      def conditions_for_mostly_active
        [%(deactivated = ? AND 
           (email_verified IS NULL OR email_verified = ?) AND
           (last_sign_in_at IS NOT NULL AND
            last_sign_in_at >= ?)),
         false, true, TIME_AGO_FOR_MOSTLY_ACTIVE]
      end
    end
end

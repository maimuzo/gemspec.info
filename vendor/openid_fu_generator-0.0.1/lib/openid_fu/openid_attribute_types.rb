module OpenID
  module AX
    module AttrTypes
      BASE_NS_URI = 'http://schema.openid.net/types/'

      TYPES = {
        # Name
        :nickname => 'namePerson/friendly',
        :full_name => 'namePerson',
        :name_prefix => 'namePerson/prefix',
        :first_name => 'namePerson/first',
        :last_name => 'namePerson/last',
        :middle_name => 'namePerson/middle',
        :name_suffix => 'namePerson/suffix',
        :company_name => 'company/name',
        :job_title => 'company/title',
        :birth_date => 'birthDate',
        :birth_year => 'birthDate/birthYear',
        :birth_month => 'birthDate/birthMonth',
        :birth_day => 'birthDate/birthday',
        :phone => 'phone/default',
        :phone_home => 'phone/home',
        :phone_business => 'phone/business',
        :phone_mobile => 'phone/cell',
        :phone_fax => 'phone/fax',
        # Address
        :address => 'contact/postalAddress/home',
        :address2 => 'contact/postalAddressAdditional/home',
        :city => 'contact/city/home',
        :state => 'contact/state/home',
        :country => 'contact/country/home',
        :postal_code => 'contact/postalCode/home',
        :business_address => 'contact/postalAddress/business',
        :business_address2 => 'contact/postalAddressAdditional/business',
        :business_city => 'contact/city/business',
        :business_state => 'contact/state/business',
        :business_country => 'contact/country/business',
        :business_code => 'contact/postalCode/business',
        # Email
        :email => 'contact/email',
        # IM
        :aol_im => 'contact/IM/AIM',
        :icq_im => 'contact/IM/ICQ',
        :msn_im => 'contact/IM/MSN',
        :yahoo_im => 'contact/IM/Yahoo',
        :jabber_im => 'IM/Jabber',
        :skype_im => 'contact/IM/Skype',
        # Web Sites
        :web => 'contact/web/default',
        :blog => 'contact/web/blog',
        :linkedin_url => 'contact/web/Linkedin',
        :amazon_url => 'contact/web/Amazon',
        :flickr_url => 'contact/web/Flickr',
        :del_icio_us_url => 'contact/web/Delicious',
        # Audio / Video Greetings
        :spoken_name => 'media/spokenname',
        :audio_greeting => 'media/greeting/audio',
        :video_greeting => 'media/greeting/video',
        # Image
        :image => 'media/image/default',
        :square_image => 'media/image/aspect11',
        :aspect43_image => 'media/image/aspect43',
        :aspect34_image => 'media/image/aspect34',
        :favicon_image => 'media/image/favicon',
        # Other Personal Details /P Preferences
        :gender => 'person/gender',
        :lanugage => 'pref/language',
        :timezone => 'pref/timezone',
        :biography => 'media/biography'
      }

      # Convinience method for Type URI
      def self.type_uri(key)
        return nil unless TYPES.key?(key)
        BASE_NS_URI + TYPES[key]
      end
    end
  end
end

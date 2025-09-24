###
# WP-CLI Documentation: https://developer.wordpress.org/cli/commands/
# INITIALIZE PROJECT.
# To run all these commands all together, place this file to ROOT folder of WordPress
# and call command inside ROOT folder of WordPress: bash WP-CLI-INIT.sh
###

### WP-CONFIG.PHP https://developer.wordpress.org/cli/commands/config/set/
wp config set WP_DEBUG true --placement=before --anchor='$table_prefix' --raw --separator="\n\n"
wp config set WP_DEBUG_LOG true --placement=before --anchor='$table_prefix' --raw --separator="\n\n"
wp config set WP_DEBUG_DISPLAY false --placement=before --anchor='$table_prefix' --raw --separator="\n\n"
wp config set DISALLOW_FILE_EDIT true --placement=before --anchor='$table_prefix' --raw --separator="\n\n"
wp config set WP_POST_REVISIONS 15 --placement=before --anchor='$table_prefix' --raw --separator="\n\n"
wp config set WP_AUTO_UPDATE_CORE minor --placement=before --anchor='$table_prefix' --separator="\n\n"

### to get value of ENV use function wp_get_environment_type() ('staging' === wp_get_environment_type())
# Possible values: 'local', 'development', 'staging', 'production' - default is 'production'
wp config set WP_ENVIRONMENT_TYPE staging --placement=before --anchor='$table_prefix' --separator="\n\n"

### CONSTANTS
readonly ADMIN_EMAIL=test@test.com
readonly SITE_TITLE="Site name"

WP_ENV_TYPE=$(wp config get WP_ENVIRONMENT_TYPE)
if [ "$WP_ENV_TYPE" != "production" ]; then
    readonly PLUGIN_INSTALL="
    contact-form-7
    mailgun
    better-search-replace
    wordpress-seo
    "
else
  readonly PLUGIN_INSTALL="
  contact-form-7
  better-search-replace
  cookie-law-info
  google-site-kit
  mailgun
  wordpress-seo
  "
fi

# mailgun constants
readonly MAILGUN_DOMAIN=test.test.com
readonly MAILGUN_APIKEY=key-abc
readonly MAILGUN_EMAIL_REPLY=noreply@test.test.com

# acf constants
readonly ACF_LICENSE=TEST-111asd222
### END CONSTANTS

### WP SETTINGS https://developer.wordpress.org/cli/commands/option/update/
wp option update date_format Y-m-d
wp option update blog_public 0                      # Search engine visibility checkbox in admin: 1-unchecked, 0-checked
wp option update admin_email $ADMIN_EMAIL
wp option update blogname "$SITE_TITLE"
wp option update comment_moderation 1               # Comment must be manually approved = 1 / 0
wp option update permalink_structure "/%postname%/"
wp option update default_comment_status closed      # Allow people to submit comments on new posts = open / closed
wp option update thumbnail_crop 0                   # Media Settings: Do not Crop thumbnail, only resize

### USER - Add New {login} {email} {--role=} https://developer.wordpress.org/cli/commands/user/create/
#wp user create 1@test.com 1@test.com --role=administrator --user_pass="1@test.com" --first_name="Developer" --last_name="Think"

### USER - Delete and Reassign posts to another https://developer.wordpress.org/cli/commands/user/delete/
#wp user delete 2@test.com --reassign="$(wp user get $ADMIN_EMAIL --field=ID)" --yes

### PLUGINS - https://developer.wordpress.org/cli/commands/plugin/
wp plugin install $PLUGIN_INSTALL          # ! DO NOT QUOTE THIS VARIABLE in "" - error plugins installation
wp plugin activate $PLUGIN_INSTALL         # ! DO NOT QUOTE THIS VARIABLE in "" - error plugins activation

wp plugin deactivate hello                  # wp plugin deactivate plugin1 plugin2 plugin3
wp plugin delete hello                      # wp plugin delete plugin1 plugin2 plugin3
#wp plugin deactivate --uninstall --all     # if plugin has already been deactivated in admin it will not be deleted here
#wp plugin delete --all                     # delete plugin any way

### OPTIONS
## https://developer.wordpress.org/cli/commands/option/patch/
## update - inside serialized array fails if the key does not exist. Adds new or updates if value is not serialized array
## insert - inside serialized array adds new pair <key-value> if key doesn't exist AND updates value if the key exists

### Mailgun - PLUGIN SETTINGS - option_name "mailgun" (value - serialized)
IS_MAILGUN_SET=$(wp option get mailgun --quiet)
if [[ -z $IS_MAILGUN_SET ]]; then
  wp option add mailgun '{}' --format=json                          # this call need only to add option "mailgun" in database
fi

wp option patch insert mailgun region eu                            # us / eu  == ("U.S./North America" / "Europe" )
wp option patch insert mailgun domain $MAILGUN_DOMAIN
wp option patch insert mailgun apiKey $MAILGUN_APIKEY
wp option patch insert mailgun from-address $MAILGUN_EMAIL_REPLY    # From Address
wp option patch insert mailgun override-from 1                      # 1 / 0 - Override "From" Details (yes/no)

### ACF Pro - PLUGIN SETTINGS - option_name "acf_pro_license" (value - string)
## https://developer.wordpress.org/cli/commands/option/update/
wp option update acf_pro_license $ACF_LICENSE             # Adds new pair <key-value> or update value by key "acf_pro_license"

### Yoast - PLUGIN SETTINGS - option_name "wpseo_titles" (value - serialized)
wp option patch insert wpseo_titles disable-author 1        # Author Archive
wp option patch insert wpseo_titles disable-date 1          # Date Archive
wp option patch insert wpseo_titles disable-post_format 1   # Format archives

### END

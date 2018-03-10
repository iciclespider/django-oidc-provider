
import pkg_resources


default_app_config = 'oidc_provider.apps.OIDCProviderConfig'


__version__ = pkg_resources.resource_string(__name__, 'VERSION').decode('utf-8').strip()
if pkg_resources.resource_exists(__name__, 'RELEASE'):
    __version__ += '+' + pkg_resources.resource_string(__name__, 'RELEASE').decode('utf-8').strip()

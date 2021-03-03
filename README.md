# LocomotiveEngineGeolocationLock

A Locomotive CMS Extension to allow Geolocation Lock based on users IP address.

Features
- Figure out users country based on IP (using `ipstack.com`)
- Redirect users from certain country to specific URL
- Use custom country resolve service
- Caching of requests for 1 day to speed up the service
- Test IPs by passing a parameter to the URL


## Usage

Add the gem in your `Gemfile` after loading the locomotivecms

```
gem 'locomotivecms'
gem 'locomotive_engine_geolocation_lock', git: 'https://github.com/xremix/locomotive_engine_geolocation_lock', require: true
```


## Configuration

To let user of the backoffice add countries you will need to add the following handle(s) to your engines code:
`request_geolocation_lock_countries`

### Geolocation Service
You can specify your own geolocation IP in the .env file
```
GEOLOCATION_URL=http://my_service.io/%s
```
The ip will get replaced with `%s`

If you are using the default service from [ipstack](https://ipstack.com/documentation) please provide an environment variable `GEOLOCATION_ACCESS_KEY` with your access key.
The plugin supports setting the header `X-Api-Key` if you set up an environment variable named `GEOLOCATION_X_API_KEY`.

### Redirect Handle
Specify your own page handle users from locked countries should get redirected to by specificng the following environment variable
```
GEOLOCATION_LOCK_PAGE_HANDLE
```


## Test
You can test the functionality by passing a parameter to the site like `my_website.io/?geo_ip=TESTIPADDRESS`  
*Warning, this works only if the rails environment is set to development*

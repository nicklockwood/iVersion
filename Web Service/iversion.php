<?php

/*

NOTE: this web service has been updated to make use of the official App Store search API, and as such is no longer in danger of violating Apple's terms and conditions.

*/

//choice of 3 platforms to search
define ('IPHONE', 'software');
define ('IPAD', 'iPadSoftware');
define ('MAC', 'macSoftware');

//app config - best to hard code this to avoid abuse
$platform = IPAD;
$app_store_id = 355313284;
$developer = 'Charcoal Design';

//country and language config - you may wish to pass these in
//as query string arguments from the url, that way your app
//can request the right version based on the user's locale settings
$country = 'US';
$language = 'en_US';

//cache config
$cache_enabled = false;
$cache_file_path = '../cache/iversion_'.$app_store_id.'_'.$country.'_'.$language.'.plist';
$cache_duration = 3600; //seconds

//set mime type - strictly this should be application/x-plist
//but text is easier for debugging and works equally well
header("Content-Type:text/plain;charset=UTF-8");

//check cache
if ($cache_enabled && file_exists($cache_file_path) && time() - filemtime($cache_file_path) < $cache_duration)
{
	//return cache file
	echo file_get_contents($cache_file_path);
	return;
}

//get itunes json app data
//note that file get contents may not work with remote files on some servers,
//so you may need to replace this call with an alternative api, e.g. curl
$json = file_get_contents('http://itunes.apple.com/search?limit=200&media=software&term='.urlencode($developer).'&country='.urlencode($country).'&lang='.urlencode($language).'&attribute=softwareDeveloper&entity=software');

//find correct app in results
$data = @json_decode($json);
foreach (@$data->results as $result)
{
	if (@$result->trackId == $app_store_id)
	{
		$data = $result;
		break;
	}
}

//get version number
$version = @$data->version;

//get release notes
$release_notes = @$data->releaseNotes;

//start output buffering to capture output
ob_start();

//output plist xml header
echo '<?xml version="1.0" encoding="UTF-8"?>'

?>

<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<?php if (@$version) { ?>
	<key><?php echo $version ?></key>
	<array>
<?php if (@$release_notes) { ?>
		<string><?php echo $release_notes ?></string>
<?php } ?>
	</array>
<?php } ?>
</dict>
</plist>

<?php

//capture buffer contents
$plist = ob_get_contents();

//save to cache file
if ($cache_enabled)
{
	@file_put_contents($cache_file_path, $plist);
}

//ouput plist
ob_end_flush();

?>
<?php

//
//  iversion.php
//
//  Version 1.7.3
//
//  Created by Nick Lockwood on 17/02/2011.
//  Copyright 2011 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from either of these locations:
//
//  http://charcoaldesign.co.uk/source/cocoa#iversion
//  https://github.com/nicklockwood/iVersion
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

//choice of 3 platforms to search
define ('IPHONE', 'software');
define ('IPAD', 'iPadSoftware');
define ('MAC', 'macSoftware');

//app config - best to hard code these to avoid abuse
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

//generate itunes search query url
$url = 'http://itunes.apple.com/search?limit=200&media=software&term='.urlencode($developer).'&country='.urlencode($country).'&lang='.urlencode($language).'&attribute=softwareDeveloper&entity='.urlencode($platform);

//download json app data
if (in_array  ('curl', get_loaded_extensions()))
{
	//use curl if available
	$curl = curl_init();
	curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($curl, CURLOPT_URL, $url);
	$json = curl_exec($curl);
	curl_close($curl);
}
else
{
	//fall back to file_get_contents, which may not work with
	//remote files on some servers, depending on configuration
	$json = file_get_contents($url);
}

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
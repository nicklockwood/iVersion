<?php

/*

WARNING: Apple's developer licence agreement states:

"Neither You nor Your Application may perform any functions or link to any content, services, information or data or use any robot, spider, site search or other retrieval application or device to scrape, mine, retrieve, cache, analyze or index software, data or services provided by Apple or its licensors, or obtain (or try to obtain) any such data, except the data that Apple expressly provides or makes available to You in connection with such services. You agree that You will not collect, disseminate or use any such data for any unauthorized purpose."

It is not clear whether use of a scraping script such as this one is in violation of these terms, but linking to such a service from an App Store app is at your own discretion and is neither recommended nor endorsed by the developer.

*/

//app-specific config
$app_store_id = 355313284;
$store_locale = 'us';

//cache config
$cache_enabled = false;
$cache_file_path = '../cache/iversion_'.$app_store_id.'_'.$store_locale.'.plist';
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

//get itunes app page content
$html = file_get_contents("http://itunes.apple.com/$store_locale/app/id$app_store_id?mt=8");

//strip newlines (makes regex matching simpler)
$html = preg_replace('/[\n\r]+/', ' ', $html);

//get version number
if (preg_match('/Version:\s*<\/span>\s*([0-9.]+)/i', $html, $matches))
{
	$version = @$matches[1];
}

//get release notes:
if (preg_match("/New In Version $version\s*<\/h4>\s*<p[^>]*>(.+?)<\/p>/i", $html,$matches))
{
	$release_notes = @$matches[1];
	
	//replace line breaks and strip other html tags or entities
	$release_notes = preg_replace('/<br[^>]*>/', "\n", $release_notes);
	$release_notes = strip_tags($release_notes);
}

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
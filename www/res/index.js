$(function () {
    var tabDivs = $('div.tabs > div');

    $('div.tabs ul.nav a').click(function () {
        tabDivs.hide().filter(this.hash).show();

        $('div.tabs ul.tabNavigation a').removeClass('selected');
        $(this).addClass('selected');

        return false;
    }).filter(':first').click();
});

function log(msg) {
    $('#log').append(msg + "\n");
}

function loadViewDone(svg, error) {
    if(error) {
	log('Failed: ' + error);
	svg.text(10, 20, error, {fill: 'red'});
	return;
    }

    log('Searching charts...');
    var charts = new Array();
    $('rect[id^="so_"]', svg.root()).each(function() {
	charts.push(this.id);
    });
    log(' ' + charts.join(', '));
}

jQuery(document).ready(function() {
  var $ = jQuery;
  $('.dblist ul').addClass('clist');
  $('.dblist li > ul').each(function(i) {
    var li_parent = $(this).parent('li');
    $(this).hide();
    var sub_ul = li_parent.children('ul').remove();
    var info = li_parent.children().remove();
    li_parent.wrapInner('<a/>').find('a').addClass('cfolder collapsed').click(function() {
        $(this).toggleClass('collapsed');
        $(this).siblings('ul').toggle();
    }).mouseover(function () {
        $(this).css('cursor','pointer');
    });
    li_parent.append(info);
    li_parent.append(sub_ul);
  });
  $('ul.dbsorted').each(function() {
    var ul = $(this);
    var lis = $(this).children('li').get();
    lis.sort(function(a, b) {
      var compA = $(a).text().toUpperCase();
      var compB = $(b).text().toUpperCase();
      return (compA < compB) ? -1 : (compA > compB) ? 1 : 0;
    });
    $.each(lis, function(idx, itm) { ul.append(itm); });
  });
});

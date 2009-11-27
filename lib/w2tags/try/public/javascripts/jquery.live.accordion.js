(function($){
 $(function(){
	//HIDE THE DIVS ON PAGE LOAD	
	$("div.accordionContent").hide();
  $("#wrapper div.accordionContent>a").prepend('<img src="/stylesheets/icons/leaf.gif"/>');

	//ACCORDION BUTTON ACTION	
	$('div.accordionButton').live('click',function() {
    var prn = $(this).parent();
    var crn = $(this);
    if(crn.hasClass('open')){
       crn.removeClass('open').next().slideUp('normal');
    } else {
      prn.find('>div.accordionContent').slideUp('normal');
      prn.find('>div.accordionButton.open').removeClass('open');
		  $(this).addClass('open').next().slideDown('normal');
    }
	});
 });
 $(function(){
  $('#wrapper>.accordionButton:eq(2)').click();
  $('#wrapper>.accordionContent').find('.accordionButton:eq(0)').click();
 });
})(jQuery);
jQuery.fn.jForms = 
function(options)
{
	var lastKeypress = 0;
    var keyBuffer = '';
    var self = this;
    var defaults = {
	imagePath : '/images/niceforms/default/',
	listSize:20
	}	
	if(jQuery.browser.safari){return false;}

	var opts = jQuery.extend(defaults, options);
	var imagePath = opts.imagePath	
	
	//preload images
	var images = [imagePath + "button_left_xon.gif", imagePath + "button_right_xon.gif", 
	imagePath + "input_left_xon.gif", imagePath + "input_right_xon.gif",
	imagePath + "txtarea_bl_xon.gif", imagePath + "txtarea_br_xon.gif", 
	imagePath + "txtarea_cntr_xon.gif", imagePath + "txtarea_l_xon.gif", imagePath + "txtarea_tl_xon.gif", imagePath + "txtarea_tr_xon.gif"]
	var imgs = new Array();
	for(var i = 0; i<images.length; i++)
	{
		imgs[i] = jQuery("<img>").attr("src", images[i]);
	}

	jQuery(self).attr('autocomplete','off').addClass('niceforms');
	
	//text and passwords
	jQuery(':text,:password',self).each(function()
	{
		jQuery(this).addClass('textinput').before('<img src = "'+imagePath+'input_left.gif" class="inputCorner" />').after('<img src="'+imagePath+'input_right.gif" class="inputCorner" />').focus(function()
		{
			jQuery(this).css('background-position','bottom').prev().attr('src',imagePath+'input_left_xon.gif')
			jQuery(this).next().attr('src',imagePath+'input_right_xon.gif');

		}).blur(function()
		{
			jQuery(this).css('background-position','top').prev().attr('src',imagePath+'input_left.gif')
			jQuery(this).next().attr('src',imagePath+'input_right.gif');
		});	
	});
	
			//select boxes
jQuery('select',self).each(function ()
{
	jQuery('body').append('<ul id = "'+this.id+'_fake_list" class="fake_list"></ul>');
	jQuery(this).children().each(function()
	{
		jQuery('#'+jQuery(this).parent().attr('id')+'_fake_list').append('<li>'+jQuery(this).text()+'</li>');
	});
	jQuery('#'+this.id+'_fake_list').css('height',(jQuery('#'+this.id+'_fake_list li:first').height()+4)*(jQuery('#'+this.id+'_fake_list li').size()<opts.listSize?jQuery('#'+this.id+'_fake_list li').size():opts.listSize)).css('width',jQuery(this).width()+18).toggle();
	
	jQuery('#'+this.id+'_fake_list > li').hover(function(){jQuery(this).addClass('selected')},function(){jQuery(this).removeClass('selected');}).each(function(i)
	{
		jQuery(this).click(function(){
		var id = jQuery(this).parent().attr('id');
		jQuery('#'+id).toggle();
	    jQuery('#'+id.replace('_list','')).attr('value',jQuery(this).text());
		jQuery('#'+id.replace('_fake_list','')).attr('selectedIndex',i).change();
		jQuery('#'+id+' >  li').removeClass('selected');
		jQuery(this).addClass('selected');	
	});
	});

jQuery(this).before('<div class="selectArea" style="width:'+(jQuery(this).width()+43)+'px"><div class="left"></div><div class="right"><a class="selectButton" href="javascript:;" onclick="jQuery(\'#'+this.id+'_fake\').focus().click()"></a></div><input type = "text" class="center" style="width:'+(jQuery(this).width())+'px;cursor:default" id="'+this.id+'_fake"  value="'+this[this.selectedIndex].text+'"  /></div>').css('position','absolute').css('left','-6000px');

	jQuery('#'+this.id+'_fake').click(function(){
		jQuery('#'+this.id+'_list').focus();
		jQuery('#'+this.id+'_list').css('left',jQuery(this).offset().left-8);
		
		if((jQuery('#'+this.id+'_list').height()+jQuery(this).offset().top -document.documentElement.scrollTop) > jQuery(window).height())
		{
			jQuery('#'+this.id+'_list').css('top',jQuery(this).offset().top-jQuery('#'+this.id+'_list').height()-4);
		}
		else
		{
			jQuery('#'+this.id+'_list').css('top',jQuery(this).offset().top+jQuery(this).height()+4);
		}
		jQuery('#'+this.id+'_list > li').removeClass('selected');
		jQuery('#'+this.id+'_list > li').get(jQuery('#'+this.id.replace('_fake','')).attr('selectedIndex')).className='selected';

		
		jQuery('.fake_list:visible:not(#'+this.id+'_list)').toggle();
		$list = jQuery('#'+this.id+'_list');	
		$list.toggle();		
		var offSet = ((jQuery('.selected', $list).length>0? jQuery('.selected', $list).offset().top:0)- $list.offset().top);
		$list.animate({scrollTop: offSet});
		}).css('font-size',jQuery(this).css('font-size')).css('padding','2px 0px 2px 2px').keyup(function(e)
		{
			var pressedKey = e.charCode || e.keyCode || -1;
			var $dd = jQuery('#'+this.id.replace('_fake',''));
			jQuery('#'+this.id+'_list > li').removeClass('selected');
			switch(pressedKey)
			{
				//down
				case 40:						
					var curr = ($dd.attr('selectedIndex')+1>=jQuery('option',$dd).length?0:$dd.attr('selectedIndex')+1);
				break;
				case 38:						
					var curr = ($dd.attr('selectedIndex')-1<0?jQuery('option',$dd).length-1:$dd.attr('selectedIndex')-1);						
				break;
				case 13:
					jQuery('#'+this.id+'_list').toggle();
					return false;
				break;
				default:
				var t = new Date();
				if(t.getTime()-lastKeypress>1000)
				{
					lastKeypress=t.getTime();
					keyBuffer ='';
				}
					keyBuffer +=String.fromCharCode(pressedKey).toLowerCase();
					curr=-1;
					jQuery('#'+this.id+'_list > li').each(function(i)
					{
						if(jQuery(this).text().toLowerCase().indexOf(keyBuffer)==0&&curr==-1)
						{
							curr = i;
							return;
						}
					});
					break;
			}
			if(curr==-1)
			{
				curr=0;
			}
			jQuery(jQuery('#'+this.id+'_list > li').get(curr)).addClass('selected').focus();
			$list = jQuery('#'+this.id+'_list');
			var offSet = ((jQuery('.selected', $list).length>0? jQuery('.selected', $list).offset().top:0)- $list.offset().top);
			$list.attr('scrollTop',offSet);
			$dd.attr('selectedIndex',curr).change();
			jQuery(this).attr('value', jQuery(jQuery('#'+this.id+'_list > li').get(curr)).text());
			return false;
						
		}).focus(function()
		{
			jQuery(document).keypress(function(e)
			{
				var pressedKey = e.charCode || e.keyCode || -1;
				if(pressedKey==13)
				{
					return false;
				}
			});
		}).blur(function()
		{
			jQuery(document).unbind('keypress').unbind('click');
		});

});

	//checkboxes
	jQuery(':checkbox',self).each(function()
	{
		jQuery(this).before('<div style="margin: 1px;" id="'+this.id+'_fake"></div>');
		jQuery(this).addClass('outtaHere');
		this.checked?jQuery('label[for='+this.id+']').addClass('chosen'):'';
		jQuery('#'+this.id+'_fake').addClass(this.checked?'checkboxAreaChecked':'checkboxArea').click(function()
		{
			jQuery('label[for='+this.id.replace('_fake','')+']').click();	
			jQuery('#'+this.id.replace('_fake','')).attr('checked')?jQuery('#'+this.id.replace('_fake','')).attr('checked',''):jQuery('#'+this.id.replace('_fake','')).attr('checked','checked');
		});
		jQuery('label[for='+this.id+']').click(function()
		{
			//these are backwards on purpose -click functions are called before the checkbox is selected
			jQuery('#'+jQuery(this).attr('for')).attr('checked')?jQuery(this).removeClass('chosen'):jQuery(this).addClass('chosen');
			jQuery('#'+jQuery(this).attr('for')+'_fake').addClass(jQuery('#'+jQuery(this).attr('for')).attr('checked')?'checkboxArea':'checkboxAreaChecked').removeClass(jQuery('#'+jQuery(this).attr('for')).attr('checked')?'checkboxAreaChecked':'checkboxArea');
		});
		
	});
	//radios
	jQuery(':radio',self).each(function()
	{
		jQuery(this).after('<div style="margin: 1px;" id="'+this.id+'_fake"></div>').addClass('outtaHere');
		this.checked?jQuery('label[for='+this.id+']').addClass('chosen'):'';
		jQuery('#'+this.id+'_fake').addClass(this.checked?'radioAreaChecked':'radioArea').click(function()
		{
			jQuery(':radio[name='+jQuery('#'+this.id.replace('_fake','')).attr('name')+']').each(function()
			{
				this.checked=false;	
			});
			jQuery('#'+this.id.replace('_fake','')).attr('checked','checked');
			jQuery('label[for='+this.id.replace('_fake','')+']').click();
		});	
		jQuery('label[for='+this.id+']').click(function()
		{					
			jQuery(':radio[name='+jQuery('#'+jQuery(this).attr('for')).attr('name')+']').each(function()
			{
				jQuery('label[for='+this.id+']').removeClass('chosen');
				jQuery('#'+this.id+'_fake').addClass('radioArea').removeClass('radioAreaChecked');
				jQuery('label[for='+this.id.replace('_fake','')+']').removeClass('chosen');
			});
			jQuery(this).addClass('chosen');	
			jQuery('#'+jQuery(this).attr('for')+'_fake').addClass('radioAreaChecked');	

		})
	});
	//text areas
	jQuery('textarea',self).each(function()
	{
		jQuery(this).replaceWith('<div style="width: '+(jQuery(this).width()+20)+'px; height: '+(jQuery(this).height()+20)+'px;" class="txtarea" id = "'+this.id+'_fake"><div class="tr"><img src="'+imagePath+'txtarea_tl.gif" class="txt_corner"></div><div class="cntr"><div style="height: '+(jQuery(this).height()+10)+'px;" class="cntr_l"></div></div><div class="br"><img src="'+imagePath+'txtarea_bl.gif" class="txt_corner"></div></div>');
		jQuery('#'+this.id+'_fake .cntr').append(jQuery(this));
		
	}).focus(function()
	{
		jQuery('#'+this.id+'_fake .tr').removeClass('tr').addClass('tr_xon');
		jQuery('#'+this.id+'_fake .br').removeClass('br').addClass('br_xon');
		jQuery('#'+this.id+'_fake .cntr').removeClass('cntr').addClass('cntr_xon');
		jQuery('#'+this.id+'_fake .cntr_l').removeClass('cntr_').addClass('cntr_l_xon');
		jQuery('#'+this.id+'_fake img:first').attr('src',imagePath+'txtarea_tl_xon.gif');
		jQuery('#'+this.id+'_fake img:last').attr('src',imagePath+'txtarea_bl_xon.gif');
	}).blur(function()
	{
		jQuery('#'+this.id+'_fake .tr_xon').addClass('tr').removeClass('tr_xon');
		jQuery('#'+this.id+'_fake .br_xon').addClass('br').removeClass('br_xon');
		jQuery('#'+this.id+'_fake .cntr_xon').addClass('cntr').removeClass('cntr_xon');
		jQuery('#'+this.id+'_fake .cntr_l_xon').addClass('cntr_').removeClass('cntr_l_xon');
		jQuery('#'+this.id+'_fake img:first').attr('src',imagePath+'txtarea_tl.gif');
		jQuery('#'+this.id+'_fake img:last').attr('src',imagePath+'txtarea_bl.gif');
	});
	
	jQuery(':button,:submit',self).each(function()
	{
		jQuery(this).before('<img class="buttonImg" src="'+imagePath+'button_left.gif">').after('<img class="buttonImg" src="'+imagePath+'button_right.gif">').addClass('buttonSubmit').hover(function()
		{
			jQuery(this).prev().attr('src',imagePath+'button_left_xon.gif');
			jQuery(this).next().attr('src',imagePath+'button_right_xon.gif');
			jQuery(this).addClass('buttonSubmitHovered').removeClass('buttonSubmit');
		},
	 function()
	 {
			jQuery(this).prev().attr('src',imagePath+'button_left.gif');
			jQuery(this).next().attr('src',imagePath+'button_right.gif');
			jQuery(this).removeClass('buttonSubmitHovered').addClass('buttonSubmit');
	});
	});
	return self;
}
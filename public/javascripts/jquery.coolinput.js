/**
 * CoolInput plugin
 *
 * @version 1.1 (23/06/2008)
 * @requires jQuery v1.2.3 or later (tested on 1.2.6 packed)
 * @author Alex Weber (alexweber.info)
 *
 * Inspiration: Remy Sharp's hint plugin (http://remysharp.com/2007/01/25/jquery-tutorial-text-box-hints/)
 * 
 * Copyright (c) 2008 Alex Weber (alexweber.info) and Dimitre Lima (dmtr.org)
 *
 * NOT YET LICENSED!!!!! DISREGARD THE NEXT 3 LINES PLEASE!!
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 */

/**
 * This plugin enables predefined text to be applied to input fields when they are empty
 *
 * @example $("#myinputbox").coolinput();
 * @desc Applies coolinput functionality to the input with id="myinputbox" with default options
 *
 * @example $("input:search").coolinput({
		blurClass: 'myclass',
		iconClass: 'search',
		clearText: true
	});
 * @desc Applies coolinput functionality to the selected input boxes with custom options
 
 * @param Class to apply when blurred
 * @param Additional class to be applied
 * @param Clear input text on submit if it remains the default value?
 *
 * @return jQuery Object
 * @type jQuery
 *
 * @name $.fn.coolinput
 * @cat Plugins/Forms
 * @author Alex Weber/alex@alexweber.info,Dimitre Lima/d@dmtr.org
 */

jQuery.fn.coolinput = function(options) {
	// default options
	var settings = {
		source	  : 'title', // attribute to be used as source for default text
		blurClass : 'blur', // class to apply to blurred input elements
		iconClass : false, // specifies background image class, if any
		clearText : true  // clears default text on submit
	};

	// if any options are passed, overwrite defaults
	if(options){
		jQuery.extend(settings, options);
	}

	// return jQuery object to enable chaining
	return this.each(function (){
		// get jQuery 'this'
		var container = jQuery(this);
		// get predefined text to be used as filler when blurred
		var text = container.attr(settings.source); 
		// if we have some text to work with proceed
		if (text){ 
			// on blur, set value to pre-defined text if blank
			container.blur(function (){
				if (container.val() == ''){
					container.val(text).addClass(settings.blurClass);
				}
			})
			
			// on focus, set value to blank if filled with pre-defined text
			.focus(function (){
				if (container.val() == text){
					container.val('').removeClass(settings.blurClass);
				}
			});
			
			// clear the pre-defined text when form is submitted
			if(settings.clearText){
			  container.parents('form:first()').submit(function(){
				  if (container.val() == text){
					  container.val('').removeClass(settings.blurClass);
				  }
			  });
			}
			
			// if a background image class is specified apply it
			if(settings.iconClass){
				container.addClass(settings.iconClass);
			}
			
			// initialize all inputs to blurred state
			container.blur();
		}
	});
};
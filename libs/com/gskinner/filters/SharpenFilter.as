/**
 * SharpenFilter by Grant Skinner. Oct 24, 2005
 * Visit www.gskinner.com for documentation, updates and more free code.
 *
 * You may distribute this code freely, as long as this comment block remains intact.
 */

package com.gskinner.filters
{
	import flash.filters.ConvolutionFilter;
	
	public class SharpenFilter extends ConvolutionFilter
	{
		
		private var _amount:Number;
		
		// new constructor:
		public function SharpenFilter(p_amount:Number) {
			// have to call super first, so we'll just set a default matrix, then update it.
			super(3,3,[0,0,0,0,1,0,0,0,0],1);
			amount = p_amount;
		}
		
		public function set amount(p_amount:Number):void {
			_amount = p_amount;
			// simple math to build a sharpen convolution matrix based on the amount:
			var a:Number = p_amount/-100;
			var b:Number = a*(-8)+1;
			matrix = [a,a,a,a,b,a,a,a,a];
		}
		
		public function get amount():Number { 
			return _amount; 
		}
	}
}
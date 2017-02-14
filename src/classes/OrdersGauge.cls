/**
 * Decorator Class for RGU Orders and Activations Gauge 
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 12/5/14
 */
public with sharing class OrdersGauge {
	
	public Decimal RedStart {get; private set;}
	public Decimal RedEnd {get; private set;}
	public Decimal YellowStart {get; private set;}
	public Decimal YellowEnd {get; private set;}
	public Decimal GreenStart {get; private set;}
	public Decimal GreenEnd {get; private set;}
	public Decimal Goal {get; private set;}
	public Decimal Actual {get; private set;}

	public OrdersGauge(Decimal goal, Decimal actual) {

		this.RedStart = 0;
		this.RedEnd = goal * .70;
		this.YellowStart = this.RedEnd;
		this.YellowEnd = goal * .80;
		this.GreenStart = this.YellowEnd;
		this.GreenEnd = goal;
		this.Goal = goal;
		this.Actual = actual;
		
	}
}
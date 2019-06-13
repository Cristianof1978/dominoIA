package dominoes;

import jason.asSyntax.ASSyntax;
import jason.asSyntax.Literal;
import jason.asSyntax.parser.ParseException;

public class Domino {
	private int value1, value2;
	public Domino(int value1, int value2) {
		this.value1=value1;
		this.value2=value2;
	}
	
	public Domino(String s) {
		String [] sValues = s.substring(7,10).split(",");
		this.value1 = Integer.parseInt(sValues[0]);
		this.value2 = Integer.parseInt(sValues[1]);
		
	}
	
	public int[] getvalues() {
		int [] ret ={this.value1,this.value2};
		return ret;
	}
	
	public Literal getLiteralDomino() {
		try {
			return ASSyntax.parseLiteral("domino("+this.value1+","+this.value2+")");
		} catch (ParseException e) {
			e.printStackTrace();
			return null;
		}
	}
	public boolean equals(Domino cmp) {
		return this.value1==cmp.getvalues()[0] 	&& this.value2==cmp.getvalues()[1] 
												||
			   this.value1==cmp.getvalues()[1] 	&& this.value2==cmp.getvalues()[0];												
	}
	
}

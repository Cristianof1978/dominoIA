package dominoes;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import javax.imageio.ImageIO;
import javax.swing.BoxLayout;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTextArea;
import javax.swing.border.LineBorder;


public class DominoesTableView extends JFrame 
{
		private final Color BGDOMINOCOLOR = new Color(230,230,200);
		private final Color BGTABLECOLOR = new Color(190,255,190);
		
		private BufferedImage [] DOMINOPICS = new BufferedImage [9];
		
		private JPanel table = new JPanel(new GridBagLayout());
		
		private JLabel status = new JLabel ( "Player1 - number Of Dominoes: 7     "
  										  +  "Player2 - number Of Dominoes: 7     "
										  + " number Of Sleeping Dominoes: 14");
		private JTextArea log = new JTextArea("                Log area                \n");
		
		private ArrayList<JButton> left = new ArrayList<JButton>();
		private ArrayList<JButton> right = new ArrayList<JButton>();
		
		private int leftIndex = 0;
		private int rightIndex = 0;
			
		public DominoesTableView() {
			
			try {
				this.DOMINOPICS[0]=ImageIO.read(new File ("dominopics/0.png"));
				this.DOMINOPICS[1]=ImageIO.read(new File ("dominopics/1.png"));
				this.DOMINOPICS[2]=ImageIO.read(new File ("dominopics/2.png"));
				this.DOMINOPICS[3]=ImageIO.read(new File ("dominopics/3.png"));
				this.DOMINOPICS[4]=ImageIO.read(new File ("dominopics/4.png"));
				this.DOMINOPICS[5]=ImageIO.read(new File ("dominopics/5.png"));
				this.DOMINOPICS[6]=ImageIO.read(new File ("dominopics/6.png"));
				this.DOMINOPICS[7]=ImageIO.read(new File ("dominopics/barrah.png"));
				this.DOMINOPICS[8]=ImageIO.read(new File ("dominopics/barrav.png"));
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			this.status.setLayout(new BoxLayout(this.status, BoxLayout.Y_AXIS));
			this.log.setAlignmentY(JLabel.CENTER_ALIGNMENT);
			
			setTitle("DOMINOES");
			setPreferredSize(new Dimension(1200,600));					
			setLayout(new BorderLayout());
			
			this.table.setBackground(this.BGTABLECOLOR);
			
			this.status.setBackground(this.BGDOMINOCOLOR);
			this.status.setFont(new Font(Font.MONOSPACED, Font.BOLD, 16));
			
			this.log.setBackground(this.BGDOMINOCOLOR);
			this.log.setFont(new Font(Font.MONOSPACED, Font.BOLD, 12));
			
			add(this.table, BorderLayout.CENTER);
			add(this.status, BorderLayout.SOUTH);			
			add(this.log, BorderLayout.EAST);
			
			build();
		}
		
		public void setNextLeftDomino(int lValue, int rValue) {
			BufferedImage icon;  
			if (leftIndex==4 || leftIndex==12 || leftIndex>20)
				icon = getDominoesImage(lValue, rValue,'v');
			else if ((leftIndex>4 && leftIndex<12) || (leftIndex>21 && leftIndex<28))  
					icon = getDominoesImage(rValue, lValue,'h');
				else 
					icon = getDominoesImage(lValue, rValue,'h');
				this.left.get(leftIndex).setIcon(new ImageIcon(icon));
				this.left.get(leftIndex).setBorder(new LineBorder(Color.BLACK,3,true));
				this.left.get(leftIndex).setBackground(this.BGDOMINOCOLOR);
				this.left.get(leftIndex).revalidate();
				repaint();
				
				leftIndex++;
		}
		
		
		public void setNextRightDomino(int lValue, int rValue) {
			BufferedImage icon;  
		if (rightIndex==4 || rightIndex==12 || rightIndex>20)
			icon = getDominoesImage(lValue, rValue,'v');
		else if ((rightIndex>4 && rightIndex<12) || (rightIndex>21 && rightIndex<28))  
				icon = getDominoesImage(rValue, lValue,'h');
			else 
				icon = getDominoesImage(lValue, rValue,'h');
			this.right.get(rightIndex).setIcon(new ImageIcon(icon));
			this.right.get(rightIndex).setBorder(new LineBorder(Color.BLACK,3,true));
			this.right.get(rightIndex).setBackground(this.BGDOMINOCOLOR);
			this.right.get(rightIndex).revalidate();
			repaint();
			
			rightIndex++;
		}
		
		
		public void setFirstDomino(int lValue, int rValue) {
			this.right.get(rightIndex).setIcon(new ImageIcon(getDominoesImage(lValue, rValue,'h')));
			this.right.get(rightIndex).setBorder(new LineBorder(Color.BLACK,3,true));		
			this.right.get(rightIndex).setBackground(this.BGDOMINOCOLOR);
			this.right.get(rightIndex).revalidate();
			rightIndex++;
			leftIndex++;
		}
		
		public void updateStatus(String Player1, String Player2, int nPlayer1, int nPlayer2, int nSleepingDominoes) {	
			this.status.setText( Player1+" - number Of Dominoes: "+nPlayer1+"      "+
								 Player2+" - number Of Dominoes: "+nPlayer2+"      "+	
								 "number Of Sleeping Dominoes: "+nSleepingDominoes);
		}
		
		
		public void endOFMatch(String msg) {
			JOptionPane.showMessageDialog(this, msg);
		}
		
		public void appendLog(String msg) {
			this.log.append(msg);
		}
		private void build(){
			JButton tmp = new JButton("");						
			tmp.setBackground(this.BGTABLECOLOR);
			tmp.setBorder(new LineBorder(this.BGTABLECOLOR,3,true));
			//tmp.setIcon(new ImageIcon(emptyImage()));
			GridBagConstraints c = new GridBagConstraints();
			c.gridx=3;
			c.gridy=7;
			this.table.add (tmp,c);
			this.left.add(tmp);
			this.right.add(tmp);
			
			
			fillLeft(c.gridx-1, c.gridy);
			fillRight(c.gridx+1, c.gridy);
						
			setVisible(true);
		    pack();
		    setLocationRelativeTo(null);	   
		    		    
		    setDefaultLookAndFeelDecorated(true);
		    
		}	
		private void fillLeft(int x, int y) {	
			GridBagConstraints c = new GridBagConstraints();
			c.gridx=x;
			c.gridy=y;
			boolean left=false;
			boolean corner=false;
			for (int i=0; i<27; i++) {			
				
				ImageIcon icon;
				
				if ((c.gridx==-1) || (c.gridx==7)){
					corner=true;
					c.gridy--;
					left = !left;
					if (c.gridx==-1) {
						c.gridx=0;					
						icon =new ImageIcon(emptyImage('v'));
						c.anchor=GridBagConstraints.WEST;						
					}
					else { 
						c.gridx=6;
						icon =new ImageIcon(emptyImage('v'));
						c.anchor=GridBagConstraints.EAST;
					}
					
				}
				else {
					corner=false;
					icon =new ImageIcon(emptyImage('h'));
					c.anchor=GridBagConstraints.CENTER;
				}		
				
				JButton tmp = new JButton("");
				tmp.setBackground(this.BGTABLECOLOR);
				tmp.setBorder(new LineBorder(this.BGTABLECOLOR,3,true));
				tmp.setIcon(icon);
				this.left.add(tmp);
				this.table.add(tmp,c);
				if (corner){
					c.gridy--;					
				}
				else  if (left) 
						c.gridx++;
					  else 
						c.gridx--;
				
			}
		}
		private void fillRight(int x, int y) {
			GridBagConstraints c = new GridBagConstraints();
			c.gridx=x++;
			c.gridy=y;
			boolean left=false;
			boolean corner=false;
			for (int i=0; i<27; i++) {			
				
				ImageIcon icon;
				
				if ((c.gridx==-1) || (c.gridx==7)){
					corner=true;
					c.gridy++;
					left = !left;
					if (c.gridx==-1) {
						c.gridx=0;					
						icon =new ImageIcon(emptyImage('v'));
						c.anchor=GridBagConstraints.WEST;						
					}
					else { 
						c.gridx=6;
						icon =new ImageIcon(emptyImage('v'));
						c.anchor=GridBagConstraints.EAST;
					}
					
				}
				else {
					corner=false;
					icon =new ImageIcon(emptyImage('h'));
					c.anchor=GridBagConstraints.CENTER;
				}		
				
				JButton tmp = new JButton("");
				tmp.setBackground(this.BGTABLECOLOR);
				tmp.setBorder(new LineBorder(this.BGTABLECOLOR,3,true));
				tmp.setIcon(icon);
				this.right.add(tmp);
				this.table.add(tmp,c);
				if (corner){
					c.gridy++;					
				}
				else  if (left) 
						c.gridx--;
					  else 
						c.gridx++;
				
			}
		}
		
		
		private BufferedImage getDominoesImage(int lv, int rv,char r) {
			int x=67;
			int y=25;
			if (r=='v') {
				x=25;
				y=67;
			}			
			BufferedImage bi= new BufferedImage(
	                x, 
	                y, 
	                BufferedImage.TYPE_INT_ARGB);
			Graphics g = bi.getGraphics();
			if (r=='v') {
				g.drawImage(this.DOMINOPICS[lv], 0, 0, null);
				g.drawImage(this.DOMINOPICS[7] , 0, 30, null);
				g.drawImage(this.DOMINOPICS[rv] , 0, 42, null);
			}
			else {
				g.drawImage(this.DOMINOPICS[lv], 0, 0, null);
				g.drawImage(this.DOMINOPICS[8] , 30, 0, null);
				g.drawImage(this.DOMINOPICS[rv] , 42, 0, null);
			}
	        g.dispose();
	        return bi;
	    }
		private BufferedImage emptyImage(char r) {
			int x=67;
			int y=25;
			if (r=='v') {
				x=25;
				y=67;
			}
				
	        BufferedImage bi = new BufferedImage(
	                x, 
	                y, 
	                BufferedImage.TYPE_INT_ARGB);
	        Graphics g = bi.getGraphics();	        
	        g.dispose();
	        return bi;
	    }
		
}
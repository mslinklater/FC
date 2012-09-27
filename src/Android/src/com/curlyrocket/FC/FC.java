package com.curlyrocket.FC;

public class FC {
	
	static {
		System.loadLibrary( "cr2" );
	}	

	private static FC instance = null;
		
	public static FC Instance() 
	{
		if( instance == null )
		{
			instance = new FC();
		}
		return instance;
	}
	
	public String Test()
	{
		return "FC is the best !";
	}
	
	public void VoidOne()
	{
	}
}
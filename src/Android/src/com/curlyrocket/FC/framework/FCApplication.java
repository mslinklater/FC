package com.curlyrocket.FC.framework;

public class FCApplication {
	static {
		System.loadLibrary( "cr2" );
	}	
	
	public native void JNIInstance();
	
	private static FCApplication instance = null;
	
	public static FCApplication Instance() 
	{
		if( instance == null )
		{
			instance = new FCApplication();
		}
		return instance;
	}
	
	protected FCApplication() 
	{
		JNIInstance();
	}

	public String GetText()
	{
		return "FCApplication OK";
	}	
}

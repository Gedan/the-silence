package classes.Engine.Combat.SpaceCombat 
{
	/**
	 * ...
	 * @author Gedan
	 */
	public function formatDamageOutput(dResult:AttackDamageResult):String
	{
		var str:String = " <b>(";
		
		if (dResult.wasCrit) str += "Critical! ";
		str += dResult.totalDamage;
		
		str += ")</b>";
		
		return str;
	}

}
<?
class Bob {

}


class Singleton
{

  // Hold an instance of the class
  private static $instance;
  
  const boinstance = 17;
  
 var $bob = '';
 var $_bob = '';
  public static $erreurPML = '45';

  public $erreurPML2 = '45';
 
  // A private constructor; prevents direct creation of object
  private function __construct()
  {
     echo 'I am constructed';
     $t = new Bob();
  }
  
  // The singleton method
  public static function factory()
  {
     if (!isset(self::$instance)) {
	$classname = __CLASS__;
	self::$instance = new $classname;
     }
     return self::$instance;
  }

  final function err2(& $txt, $toto =0) {
  }
  
  static function err($txt /* */, $toto =0) {

	static $bob; $bob .= $txt;
	
	Singleton::$erreurPML .= $txt;	
	Singleton::factory()->erreurPML2 .= $txt;	
  }
}

$time = time() + microtime();

for($i = 0; $i < 20; $i++) {
	Singleton::err("vhb'");
}

var_dump(time() + microtime() - $time);

?>

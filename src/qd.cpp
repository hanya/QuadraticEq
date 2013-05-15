
#include "qd.hpp"

#include <math.h>

#include <rtl/ustrbuf.hxx>

#define IMPLE_NAME "mytools.sheet.QuadraticEquationAddIn"
#define SERVICE_NAME IMPLE_NAME

#define A2S( str ) ::rtl::OUString( RTL_CONSTASCII_USTRINGPARAM( str ) )


namespace mytools { namespace sheet {

using namespace ::com::sun::star::uno;


QuadraticEquationAddIn::QuadraticEquationAddIn( /* Reference< XComponentContext > const & xContext */ )
{
}

QuadraticEquationAddIn::~QuadraticEquationAddIn()
{
}

Reference< XInterface > QuadraticEquationAddIn::create( const Reference< XComponentContext > & /* xContext */ )
{
    return static_cast< ::cppu::OWeakObject * >( new QuadraticEquationAddIn( /* xContext */ ) );
}


// XQuadraticEquationAddIn
Any SAL_CALL QuadraticEquationAddIn::quadratic( double a, double b, double c, ::sal_Int32 nType ) 
        throw (::com::sun::star::lang::IllegalArgumentException, RuntimeException)
{
    // ToDo check overflow
    static const ::rtl::OUString sAdd = A2S( "+" );
    static const ::rtl::OUString sSub = A2S( "-" );
    static const ::rtl::OUString sI = A2S( "i" );
    
    if ( nType < 0 || 2 < nType )
        throw ::com::sun::star::lang::IllegalArgumentException( 
            ::rtl::OUString(), Reference< XInterface >(), 3 );
    
    Any ret;
    const double v = b * b - 4 * a * c;
    if ( v >= 0 )
    {
        const double r = ( -b + ( nType == 0 ? sqrt( v ) : - sqrt( v ) ) ) / 2.0 / a;
        ret <<= r;
    }
    else
    {
        const double r = ( -b ) / 2.0 / a;
        const double i = sqrt( -v ) / 2.0 / a;
        
        ::rtl::OUStringBuffer buff( 50 );
        buff.append( ::rtl::OUString::valueOf( r ) )
            .append( ( nType == 0 ? sAdd : sSub ) )
            .append( ::rtl::OUString::valueOf( i ) )
            .append( sI );
        ret <<= buff.makeStringAndClear();
    }
    return ret;
}

/*
// XServiceInfo
::rtl::OUString SAL_CALL QuadraticEquationAddIn::getImplementationName(  ) throw (RuntimeException)
{
    return QuadraticEquationAddIn::getImplementationName_Static();
}

::sal_Bool SAL_CALL QuadraticEquationAddIn::supportsService( const ::rtl::OUString& ServiceName ) 
        throw (RuntimeException)
{
    return ServiceName.equals( A2S( SERVICE_NAME ) ) || 
           ServiceName.equals( A2S( "com.sun.star.sheet.AddIn" ) );
}

Sequence< ::rtl::OUString > SAL_CALL QuadraticEquationAddIn::getSupportedServiceNames(  ) 
        throw (RuntimeException)
{
    return QuadraticEquationAddIn::getSupportedServiceNames_Static();
}
*/

::rtl::OUString QuadraticEquationAddIn::getImplementationName_Static() 
{
    return ::rtl::OUString::createFromAscii( IMPLE_NAME );
}

Sequence< ::rtl::OUString > QuadraticEquationAddIn::getSupportedServiceNames_Static() 
{
    Sequence< ::rtl::OUString > aRet( 2 );
    ::rtl::OUString * pArray = aRet.getArray();
    pArray[0] = A2S( SERVICE_NAME );
    pArray[1] = A2S( "com.sun.star.sheet.AddIn" );
    return aRet;
}

}; }; // namespace

//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("Payback_Free.res");
USEFORM("Launcher.cpp", FLauncher);
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
        try
        {
                 Application->Initialize();
                 Application->CreateForm(__classid(TFLauncher), &FLauncher);
                 Application->Run();
        }
        catch (Exception &exception)
        {
                 Application->ShowException(&exception);
        }
        return 0;
}
//---------------------------------------------------------------------------

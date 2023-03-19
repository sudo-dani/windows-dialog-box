-- Hello! before you use this script, please be warned this might mess up your system if you dont change decals properly! now, thanks for using the script!
  
  
  
require "ffi"

module MessageBox
  extend FFI::Library

  ffi_lib 'user32'
  ffi_convention :stdcall

  attach_function :message_box, :MessageBoxA,[ :pointer, :string, :string, :uint ], :int
end

class BrowseInfo < FFI::Struct
  # see: http://msdn.microsoft.com/en-us/library/windows/desktop/bb773205(v=vs.85).aspx
  layout :hwndOwner, :pointer,
         :pidlRoot, :pointer,
         :pszDisplayName, :pointer,
         :lpszTitle, :pointer,
         :ulFlags, :uint,
         :lpfn, :pointer,
         :lParam, :int,
         :iImage, :int    
end

module GetFolder
  extend FFI::Library

  ffi_lib 'shell32'
  ffi_convention :stdcall

  attach_function :SHBrowseForFolder, [:pointer], :pointer
  
end

module IDtoPath
  extend FFI::Library

  ffi_lib 'shell32'
  ffi_convention :stdcall

  attach_function :SHGetPathFromIDList, [:pointer, :buffer_out], :bool
  
end

class OpenFileName < FFI::Struct
  #see: http://msdn.microsoft.com/en-us/library/windows/desktop/ms646839(v=vs.85).aspx
  layout :lStructSize, :uint,
         :hwndOwner, :pointer,
         :hInstance, :pointer,
         :lpstrFilter, :pointer,
         :lpstrCustomFilter, :pointer,
         :nMaxCustFilter, :uint,
         :nFilterIndes, :uint,
         :lpstrFile, :pointer,
         :nMaxFile, :uint,
         :lpstrFileTitle, :pointer,
         :nMaxFileTitle, :uint,
         :lpstrInitialDir, :pointer,
         :lpstrTitle, :pointer,
         :Flags, :uint,
         :nFileOffset, :int16,
         :nFileExtension, :int16,
         :lpstrDefExt, :pointer,
         :lCustData, :pointer,
         :lpfnHook, :pointer,
         :lpTemplateName, :pointer,
         :pvReserved, :int, #:void
         :dwReserved, :uint,
         :FlagEx, :uint
         

end

module GetFile
  extend FFI::Library
  
  ffi_lib 'comdlg32'
  ffi_convention :stdcall
  
  attach_function :GetOpenFileName, :GetOpenFileNameA, [:pointer], :bool
  attach_function :CommDlgExtendedError, [], :uint
end

module GetPath
  extend FFI::Library
  ffi_lib 'Kernel32'
  ffi_convention :stdcall
  
  attach_function :get_path, :GetCurrentDirectoryA, [:uint,:pointer],:uint
end

def getfilepath(tle="Open")
  ofn=OpenFileName.new
  #puts ofn.methods
  #gets
  #print ofn.size
  ofn[:lStructSize]=ofn.size
  ofn[:Flags]=0x00080000
  ofn[:lpstrFile]=FFI::MemoryPointer.new(256) 
  ofn[:lpstrTitle]=FFI::MemoryPointer.from_string(tle)
  ofn[:nMaxFile]=256
  rc=GetFile.GetOpenFileName(ofn)
  return ofn[:lpstrFile].read_string
end

def getfolderpath(tle="Select folder.")
  bi=BrowseInfo.new
  bi[:lpszTitle]=FFI::MemoryPointer.from_string(tle)
  bi[:ulFlags]=0x00000040
  
  rc = GetFolder.SHBrowseForFolder(bi)

  path=FFI::MemoryPointer.from_string(" "*256)
  IDtoPath.SHGetPathFromIDList(rc, path)
  return path.read_string
end

def showmessage(msg="Message", tle="Title", type=3)
  # The last parameter determines the buttons
  # see:  http://msdn.microsoft.com/en-us/library/windows/desktop/ms645505(v=vs.85).aspx
  rc = MessageBox.message_box(nil, msg, tle, type)
  return rc
end

def getcurrentpath
  size=256
  buffer=FFI::MemoryPointer.new(size)
  rc=GetPath.get_path(size,buffer)
  return buffer.read_string
end

module SetPath
  extend FFI::Library
  ffi_lib 'Kernel32'
  ffi_convention :stdcall
  
  attach_function :set_path, :SetCurrentDirectoryA, [:pointer], :bool

end

def setcurrentpath(path)
  buffer=FFI::MemoryPointer.from_string(path)
  rc=SetPath.set_path(buffer)
  return rc
end

#puts showmessage("Message for you!", "Hello!")
#puts getfilepath("Select the file you want.")
#puts getfolderpath("Select the folder you want.")
#puts getcurrentpath
#puts setcurrentpath('C:\\Users\\')
#puts Dir.pwd

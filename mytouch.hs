-- Made by Andre Pinto
-- Notes:
--   -This implementation does not have -d (--date=STRING) and -h (--no-dereference)
--   -This implementation changed the way of how -t is handled
--   -This implementation does not support concatened flags (-amf should be -a -m -f)

-- Imports
import System.Environment(getArgs)
import System.Exit (exitSuccess, exitFailure)
import System.Directory (setModificationTime, setAccessTime, doesDirectoryExist, doesFileExist, getAccessTime, getModificationTime)
import Data.Time (timeZoneName, getTimeZone, getCurrentTime, defaultTimeLocale)
import Data.Time.Format (parseTimeM)
import Data.Time.Clock (UTCTime)
import qualified Control.Monad
import System.IO (openFile)
import GHC.IO.IOMode (IOMode(ReadWriteMode))

version = "1.0"

-- Print help message and exit
showHelpOptionAndExit = do
    putStr "Try: 'touch"
    -- progName <- getProgName
    -- putStr progName
    putStrLn " --help' for more information."
    exitFailure

-- Print version and exit
printVersionAndExit = do
    putStrLn "touch (GNU coreutils) 8.30"
    putStrLn "Copyright (C) 2018 Free Software Foundation, Inc."
    putStrLn "License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>."
    putStrLn "This is free software: you are free to change and redistribute it."
    putStrLn "There is NO WARRANTY, to the extent permitted by law."
    putStrLn ""
    putStrLn "Written by Paul Rubin, Arnold Robbins, Jim Kingdon,"
    putStrLn "David MacKenzie, and Randy Smith."

    -- putStr "touch in haskell\nVersion: "
    -- putStrLn version
    -- putStrLn "\nWritten by Andre Pinto."
    exitSuccess

-- Print help menu and exit
printHelpMenuAndExit = do
    putStrLn "Usage: touch [OPTION]... FILE..."
    putStrLn "Update the access and modification times of each FILE to the current time."
    putStrLn ""
    putStrLn "A FILE argument that does not exist is created empty, unless -c or -h"
    putStrLn "is supplied."
    putStrLn ""
    putStrLn "A FILE argument string of - is handled specially and causes touch to"
    putStrLn "change the times of the file associated with standard output."
    putStrLn ""
    putStrLn "Mandatory arguments to long options are mandatory for short options too."
    putStrLn "  -a                     change only the access time"
    putStrLn "  -c, --no-create        do not create any files"
    putStrLn "  -d, --date=STRING      parse STRING and use it instead of current time"
    putStrLn "  -f                     (ignored)"
    putStrLn "  -h, --no-dereference   affect each symbolic link instead of any referenced"
    putStrLn "                         file (useful only on systems that can change the"
    putStrLn "                         timestamps of a symlink)"
    putStrLn "  -m                     change only the modification time"
    putStrLn "  -r, --reference=FILE   use this file's times instead of current time"
    putStrLn "  -t STAMP               use [[CC]YY]MMDDhhmm[.ss] instead of current time"
    putStrLn "      --time=WORD        change the specified time:"
    putStrLn "                           WORD is access, atime, or use: equivalent to -a"
    putStrLn "                           WORD is modify or mtime: equivalent to -m"
    putStrLn "      --help     display this help and exit"
    putStrLn "      --version  output version information and exit"
    putStrLn ""
    putStrLn "Note that the -d and -t options accept different time-date formats."
    putStrLn ""
    putStrLn "GNU coreutils online help: <https://www.gnu.org/software/coreutils/>"
    putStrLn "Full documentation at: <https://www.gnu.org/software/coreutils/touch>"
    putStrLn "or available locally via: info '(coreutils) touch invocation'"
    -- progName <- getProgName
    -- putStr "Usage: ./"
    -- putStr progName
    -- putStrLn " [OPTION]... FILE..."
    -- putStrLn "Update the access and modification times of each FILE to the current time."
    -- putStrLn "\nA FILE argument that does not exist is created empty, unless -c or -h"
    -- putStrLn "is supplied."
    -- putStrLn "\nA FILE argument string of - is handled specially and causes touch to"
    -- putStrLn "change the times of the file associated with standard output."
    -- putStrLn "\nMandatory arguments to long options are mandatory for short options too."
    -- putStrLn "  -a                    change only the acess time"
    -- putStrLn "  -c, --no-create       do not create any files"
    -- putStrLn "  -f                    (ignored)"
    -- putStrLn "  -m                    change only the modification time"
    -- putStrLn "  -r, --reference=FILE  use this file's times instead of current time"
    -- putStrLn "  -t STAMP              use YYYYMMDDhhmm.ss instead of current time"
    -- putStrLn "    --time=WORD         change the specified time:"
    -- putStrLn "                          WORD is access, atime, or use: equivalent to -a"
    -- putStrLn "                          WORD is modify or mtime: equivalent to -m"
    -- putStrLn "    --help      display this help and exit"
    -- putStrLn "    --version   output version information and exit"
    -- putStrLn "\nNote that the -d and -t options accept different time-date formats."
    exitSuccess

-- Handle args (TEST)
handleArgs (arg:args) = do
    case arg of
        "-a"                ->  do
                                    putStrLn "acess"
                                    handleArgs args
        "--time=atime"      ->  do
                                    putStrLn "acess"
                                    handleArgs args
        "--time=access"     ->  do
                                    putStrLn "acess"
                                    handleArgs args
        "--time=use"        ->  do
                                    putStrLn "acess"
                                    handleArgs args
        "-m"                ->  do
                                    putStrLn "modify"
                                    handleArgs args
        "--time=modify"     ->  do
                                    putStrLn "modify"
                                    handleArgs args
        "--time=mtime"      ->  do
                                    putStrLn "modify"
                                    handleArgs args
        "-c"                ->  do
                                    putStrLn "no create"
                                    handleArgs args
        "--no-create"       ->  do
                                    putStrLn "no create"
                                    handleArgs args
        "-f"                ->  do
                                    putStrLn "ignore"
                                    handleArgs args
        "--reference=FILE"  ->  do
                                    putStrLn "file reference"
                                    handleArgs args
        "-r"                ->  do
                                    putStrLn "file reference"
                                    handleArgs (tail args)
        "-t"                ->  do
                                    putStrLn "stamp"
                                    handleArgs (tail args)
        "-"                 ->  do
                                    putStrLn "standart output file"
                                    handleArgs args
        _                   ->  do
                                    putStr "file "
                                    putStrLn arg
                                    handleArgs args
handleArgs _ =
    return ()

-- Check invalid args
checkInvalidOrExitArgs (arg:args) = do
    -- Valid args
    if (arg `elem`   [
                        "-a",
                        "--time=atime",
                        "--time=access",
                        "--time=use",
                        "-m",
                        "--time=modify",
                        "--time=mtime",
                        "-c",
                        "--no-create",
                        "-f",
                        "-r",
                        "-t",
                        "-"
                    ] 
            || take 12 arg == "--reference=")
            || head arg /= '-' then
        checkInvalidOrExitArgs args
    else if arg == "--version" then
        printVersionAndExit
    else if arg == "--help" then
        printHelpMenuAndExit

    -- Enable files that starts with -. Stop checking cuz args is file list
    else if arg == "--" then
        return ()

    -- Bad args
    else
        do
            putStr "touch: invalid option "

            -- Output for single - bad arg
            if take 2 arg /= "--" then do
                putStr "-- '"
                putStr (tail arg)

            -- Output for more than 1 - bad arg
            else do
                putStr "'"
                putStr arg
            putStrLn "'"
            showHelpOptionAndExit
checkInvalidOrExitArgs _ =
    return ()

-- Check if args has its param when needed
checkInvalidArgsParams (arg:args) = do
    -- Stop checking cuz args is file list
    if arg == "--" then return ()
    else if arg == "-t" then
        if null args then do
            putStr "touch: option requires an argument -- '"
            putStr (tail arg)
            putStrLn "'"
            showHelpOptionAndExit
        else do
            let date = head args
            let parsedDate = parseTimeM False defaultTimeLocale "%Y%m%d%H%M.%S" date :: Maybe UTCTime
            case parsedDate of
                Just _ -> putStr ""
                _ -> do
                        putStr "touch: invalid date format '"
                        putStr date
                        putStrLn "'"
                        exitFailure
    else if arg == "-r" then
        if null args then do
            putStr "touch: option requires an argument -- '"
            putStr (tail arg)
            putStrLn "'"
            showHelpOptionAndExit
        else do
            let file = head args
            isFile <- doesFileExist file
            isDirectory <- doesDirectoryExist file
            if isFile || isDirectory then
                checkInvalidArgsParams (tail args)
            else do
                putStr "touch: failed to get attributes of '"
                putStr file
                putStrLn "': No such file or directory"
                exitFailure
    else if take 12 arg == "--reference=" then do
        let file = drop 12 arg
        isFile <- doesFileExist file
        isDirectory <- doesDirectoryExist file
        if isFile || isDirectory then
            checkInvalidArgsParams args
        else do
            putStr "touch: failed to get attributes of '"
            putStr file
            putStrLn "': No such file or directory"
            exitFailure
    else
        checkInvalidArgsParams args
checkInvalidArgsParams _ =
    return ()

-- Check if more than 1 times flag was used
checkTimesSpecified (arg:args) hasT hasR = do
    if arg == "--" then do
        return [hasT, hasR]
    else do
        let newHasT = arg == "-t"
        let newHasR = arg == "-r" || take 12 arg == "--reference="

        if hasT && newHasR || hasR && newHasT then do
            putStrLn "touch: cannot specify times from more than one source"
            showHelpOptionAndExit
        else
            checkTimesSpecified args (newHasT || hasT) (newHasR || hasR)
checkTimesSpecified _ hasT hasR = do
    return [hasT, hasR]

-- Delete first appearence of
-- deleteFirst _ [] = [] 
-- deleteFirst x (arg:args) =
--     if x == arg then
--         args
--     else
--         arg:deleteFirst x args

getArgParam (arg : args)
    | take 12 arg == "--reference=" = drop 12 arg
    | head args == "-t" || head args == "-r" = arg
    | otherwise = getArgParam args
getArgParam _ = 
    "" -- Should never go here

getAccesModifyTime args hasT hasR
    | hasT
    = do 
        let time = getArgParam (reverse args)
        currentTime <- getCurrentTime
        timeZone <- getTimeZone currentTime
        let parsedDate = parseTimeM False defaultTimeLocale "%Y%m%d%H%M.%S %z" (time ++ " " ++ timeZoneName timeZone ++ "00") :: Maybe UTCTime
        case parsedDate of { Just x -> return [x, x] }
    | hasR
    = do let file = getArgParam (reverse args)
         accesTime <- getAccessTime file
         modifyTime <- getModificationTime file
         return [accesTime, modifyTime]
    | otherwise
    = do currentTime <- getCurrentTime
         return [currentTime, currentTime]

checkCreateFile (arg:args) =
    if arg == "-c" || arg == "--no-create" then
        return False
    else
        checkCreateFile args
checkCreateFile _ =
    return True

openFileArray (arg:args) = do
    isDir <- doesDirectoryExist arg
    if isDir then
        openFileArray args
    else do
        openFile arg ReadWriteMode
        openFileArray args
openFileArray _ =
    return ()


createFiles createFile (arg:args) =
    Control.Monad.when createFile
    $ if arg == "--" then
          do openFileArray args
      else
          do case arg of
               "-a" -> createFiles createFile args
               "--time=atime" -> createFiles createFile args
               "--time=access" -> createFiles createFile args
               "--time=use" -> createFiles createFile args
               "-m" -> createFiles createFile args
               "--time=modify" -> createFiles createFile args
               "--time=mtime" -> createFiles createFile args
               "-c" -> createFiles createFile args
               "--no-create" -> createFiles createFile args
               "-f" -> createFiles createFile args
               "--reference=FILE" -> createFiles createFile args
               "-r" -> createFiles createFile (tail args)
               "-t" -> createFiles createFile (tail args)
               "-" -> createFiles createFile args
               _ -> do 
                        isDir <- doesDirectoryExist arg
                        if isDir then
                            createFiles createFile args
                        else do
                            openFile arg ReadWriteMode
                            createFiles createFile args
createFiles _ _ =
    return ()

checkIfHasFile (arg:args) =
    if arg == "--" then
        if null args then do
            putStrLn "touch: missing file operand"
            showHelpOptionAndExit
        else
            return True
    else
        case arg of
            "-a" -> checkIfHasFile args
            "--time=atime" -> checkIfHasFile args
            "--time=access" -> checkIfHasFile args
            "--time=use" -> checkIfHasFile args
            "-m" -> checkIfHasFile args
            "--time=modify" -> checkIfHasFile args
            "--time=mtime" -> checkIfHasFile args
            "-c" -> checkIfHasFile args
            "--no-create" -> checkIfHasFile args
            "-f" -> checkIfHasFile args
            "--reference=FILE" -> checkIfHasFile args
            "-r" -> checkIfHasFile (tail args)
            "-t" -> checkIfHasFile (tail args)
            "-" -> return True
            _ -> return True
checkIfHasFile _ = do
    putStrLn "touch: missing file operand"
    showHelpOptionAndExit

touchArray (arg:args) accesTime modifyTime changeAcces changeModify = do
    if arg == "-" then do
        if changeAcces then
            setAccessTime "/proc/self/fd/1" accesTime
        else
            putStr ""
        if changeModify then
            setModificationTime "/proc/self/fd/1" modifyTime
        else
            putStr ""

    else do
        fileExists <- checkIfExists arg
        if changeAcces && fileExists then
            setAccessTime arg accesTime
        else
            putStr ""
        if changeModify && fileExists then
            setModificationTime arg modifyTime
        else
            putStr ""
    
    touchArray args accesTime modifyTime changeAcces changeModify
touchArray _ _ _ _ _ = 
    return ()

touch (arg:args) accesTime modifyTime changeAcces changeModify =
    if arg == "--" then
        touchArray args accesTime modifyTime changeAcces changeModify
    else
        case arg of
            "-a" -> touch args accesTime modifyTime changeAcces changeModify
            "--time=atime" -> touch args accesTime modifyTime changeAcces changeModify
            "--time=access" -> touch args accesTime modifyTime changeAcces changeModify
            "--time=use" -> touch args accesTime modifyTime changeAcces changeModify
            "-m" -> touch args accesTime modifyTime changeAcces changeModify
            "--time=modify" -> touch args accesTime modifyTime changeAcces changeModify
            "--time=mtime" -> touch args accesTime modifyTime changeAcces changeModify
            "-c" -> touch args accesTime modifyTime changeAcces changeModify
            "--no-create" -> touch args accesTime modifyTime changeAcces changeModify
            "-f" -> touch args accesTime modifyTime changeAcces changeModify
            "--reference=FILE" -> touch args accesTime modifyTime changeAcces changeModify
            "-r" -> touch (tail args) accesTime modifyTime changeAcces changeModify
            "-t" -> touch (tail args) accesTime modifyTime changeAcces changeModify
            "-" -> touch args accesTime modifyTime changeAcces changeModify
            _ -> do
                    if arg == "-" then do
                        if changeAcces then
                            setAccessTime "/proc/self/fd/1" accesTime
                        else
                            putStr ""
                        if changeModify then
                            setModificationTime "/proc/self/fd/1" modifyTime
                        else
                            putStr ""
    
                    else do
                        fileExists <- checkIfExists arg
                        if changeAcces && fileExists then
                            setAccessTime arg accesTime
                        else
                            putStr ""
                        if changeModify && fileExists then
                            setModificationTime arg modifyTime
                        else
                            putStr ""    
                    
                    touch args accesTime modifyTime changeAcces changeModify
touch _ _ _ _ _= do
    return ()

checkIfExists file = do
    isFile <- doesFileExist file
    isDirectory <- doesDirectoryExist file
    if isFile || isDirectory then
        return True
    else
        return False

getChangeOption args
    | "-a" `elem` args || "--time=atime" `elem` args || "--time=access"`elem` args || "--time=use" `elem` args
    = if "-m" `elem` args || "--time=modify" `elem` args || "--time=mtime" `elem` args then
          return [True, True]
      else
          return [True, False]
    | "-m" `elem` args || "--time=modify" `elem` args || "--time=mtime" `elem` args = return [False, True]
    | otherwise = return [True, True]

-- Main
main = do
    args <- getArgs

    checkInvalidOrExitArgs args
    checkInvalidArgsParams args
    [hasT, hasR] <- checkTimesSpecified args False False

    [accesTime, modifyTime] <- getAccesModifyTime (takeWhile (/= "--") args) hasT hasR

    [changeAccess, changeModify] <- getChangeOption (takeWhile (/= "--") args)
    
    checkIfHasFile args

    createFile <- checkCreateFile (takeWhile (/= "--") args)
    createFiles createFile args

    touch args accesTime modifyTime changeAccess changeModify

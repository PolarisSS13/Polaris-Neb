#ifdef OPENDREAM
//1000-1999
// FileAlreadyIncluded trips up on modpack DMEs
#pragma FileAlreadyIncluded disabled
#pragma MissingIncludedFile error
#pragma MisplacedDirective error
#pragma UndefineMissingDirective error
#pragma DefinedMissingParen error
#pragma ErrorDirective error
#pragma WarningDirective warning
#pragma MiscapitalizedDirective error

//2000-2999
#pragma SoftReservedKeyword error
#pragma DuplicateVariable error
#pragma DuplicateProcDefinition error
#pragma PointlessParentCall error
#pragma PointlessBuiltinCall error
#pragma SuspiciousMatrixCall error
#pragma FallbackBuiltinArgument error
#pragma MalformedRange error
#pragma InvalidRange error
#pragma InvalidSetStatement error
#pragma InvalidOverride error
#pragma DanglingVarType error
#pragma MissingInterpolatedExpression error
#pragma AmbiguousResourcePath error

//3000-3999
#pragma EmptyBlock error
#pragma EmptyProc disabled
#pragma UnsafeClientAccess disabled
#pragma SuspiciousSwitchCase error
#pragma AssignmentInConditional error
#pragma AmbiguousInOrder error
#endif
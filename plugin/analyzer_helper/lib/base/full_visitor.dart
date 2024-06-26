import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'step.dart';

///访问Ast树中的所有节点
class FullVisitor extends SimpleAstVisitor {
  ///指定特征，再深度遍历过程中，符合特征则调用触发器[trigger]
  final List<AnalyzerStep> patterns;

  ///记录当前遍历路径
  final List<AnalyzerStep> currentPath;

  ///当遍历到[patterns]指定节点时执行
  final void Function(dynamic obj, AnalyzerStep step)? trigger;

  FullVisitor({
    required this.patterns,
    this.currentPath = const [],
    this.trigger,
  });

  ///visitor为深度优先遍历,对覆写节点前向推进过程中，
  ///若节点类型处于[patterns]之中，则调用[trigger]
  void forward(node) {
    AnalyzerStep? step = match(node);
    if (step != null) {
      trigger?.call(node, step);
      currentPath.add(step);
    }
    node.visitChildren(this);
  }

  AnalyzerStep? match(node) {
    List steps = patterns.where((e) => e.typeChecker(node)).toList();
    return steps.isEmpty ? null : steps.first;
  }

  @override
  visitAdjacentStrings(AdjacentStrings node) => forward(node);

  @override
  visitAnnotation(Annotation node) => forward(node);

  @override
  visitArgumentList(ArgumentList node) => forward(node);

  @override
  visitAsExpression(AsExpression node) => forward(node);

  @override
  visitAssertInitializer(AssertInitializer node) => forward(node);

  @override
  visitAssertStatement(AssertStatement node) => forward(node);

  @override
  visitAssignedVariablePattern(AssignedVariablePattern node) => forward(node);

  @override
  visitAssignmentExpression(AssignmentExpression node) => forward(node);

  @override
  visitAugmentationImportDirective(AugmentationImportDirective node) =>
      forward(node);

  @override
  visitAwaitExpression(AwaitExpression node) => forward(node);

  @override
  visitBinaryExpression(BinaryExpression node) => forward(node);

  @override
  visitBlock(Block node) => forward(node);

  @override
  visitBlockFunctionBody(BlockFunctionBody node) => forward(node);

  @override
  visitBooleanLiteral(BooleanLiteral node) => forward(node);

  @override
  visitBreakStatement(BreakStatement node) => forward(node);

  @override
  visitCascadeExpression(CascadeExpression node) => forward(node);

  @override
  visitCaseClause(CaseClause node) => forward(node);

  @override
  visitCastPattern(CastPattern node) => forward(node);

  @override
  visitCatchClause(CatchClause node) => forward(node);

  @override
  visitCatchClauseParameter(CatchClauseParameter node) => forward(node);

  @override
  visitClassDeclaration(ClassDeclaration node) => forward(node);

  @override
  visitClassTypeAlias(ClassTypeAlias node) => forward(node);

  @override
  visitComment(Comment node) => forward(node);

  @override
  visitCommentReference(CommentReference node) => forward(node);

  @override
  visitCompilationUnit(CompilationUnit node) => forward(node);

  @override
  visitConditionalExpression(ConditionalExpression node) => forward(node);

  @override
  visitConfiguration(Configuration node) => forward(node);

  @override
  visitConstantPattern(ConstantPattern node) => forward(node);

  @override
  visitConstructorDeclaration(ConstructorDeclaration node) => forward(node);

  @override
  visitConstructorFieldInitializer(ConstructorFieldInitializer node) =>
      forward(node);

  @override
  visitConstructorName(ConstructorName node) => forward(node);

  @override
  visitConstructorReference(ConstructorReference node) => forward(node);

  @override
  visitConstructorSelector(ConstructorSelector node) => forward(node);

  @override
  visitContinueStatement(ContinueStatement node) => forward(node);

  @override
  visitDeclaredIdentifier(DeclaredIdentifier node) => forward(node);

  @override
  visitDeclaredVariablePattern(DeclaredVariablePattern node) => forward(node);

  @override
  visitDefaultFormalParameter(DefaultFormalParameter node) => forward(node);

  @override
  visitDoStatement(DoStatement node) => forward(node);

  @override
  visitDottedName(DottedName node) => forward(node);

  @override
  visitDoubleLiteral(DoubleLiteral node) => forward(node);

  @override
  visitEmptyFunctionBody(EmptyFunctionBody node) => forward(node);

  @override
  visitEmptyStatement(EmptyStatement node) => forward(node);

  @override
  visitEnumConstantArguments(EnumConstantArguments node) => forward(node);

  @override
  visitEnumConstantDeclaration(EnumConstantDeclaration node) => forward(node);

  @override
  visitEnumDeclaration(EnumDeclaration node) => forward(node);

  @override
  visitExportDirective(ExportDirective node) => forward(node);

  @override
  visitExpressionFunctionBody(ExpressionFunctionBody node) => forward(node);

  @override
  visitExpressionStatement(ExpressionStatement node) => forward(node);

  @override
  visitExtendsClause(ExtendsClause node) => forward(node);

  @override
  visitExtensionDeclaration(ExtensionDeclaration node) => forward(node);

  @override
  visitExtensionOverride(ExtensionOverride node) => forward(node);

  @override
  visitExtensionTypeDeclaration(ExtensionTypeDeclaration node) => forward(node);

  @override
  visitFieldDeclaration(FieldDeclaration node) => forward(node);

  @override
  visitFieldFormalParameter(FieldFormalParameter node) => forward(node);

  @override
  visitForEachPartsWithDeclaration(ForEachPartsWithDeclaration node) =>
      forward(node);

  @override
  visitForEachPartsWithIdentifier(ForEachPartsWithIdentifier node) =>
      forward(node);

  @override
  visitForEachPartsWithPattern(ForEachPartsWithPattern node) => forward(node);

  @override
  visitForElement(ForElement node) => forward(node);

  @override
  visitFormalParameterList(FormalParameterList node) => forward(node);

  @override
  visitForPartsWithDeclarations(ForPartsWithDeclarations node) => forward(node);

  @override
  visitForPartsWithExpression(ForPartsWithExpression node) => forward(node);

  @override
  visitForPartsWithPattern(ForPartsWithPattern node) => forward(node);

  @override
  visitForStatement(ForStatement node) => forward(node);

  @override
  visitFunctionDeclaration(FunctionDeclaration node) => forward(node);

  @override
  visitFunctionDeclarationStatement(FunctionDeclarationStatement node) =>
      forward(node);

  @override
  visitFunctionExpression(FunctionExpression node) => forward(node);

  @override
  visitFunctionExpressionInvocation(FunctionExpressionInvocation node) =>
      forward(node);

  @override
  visitFunctionReference(FunctionReference node) => forward(node);

  @override
  visitFunctionTypeAlias(FunctionTypeAlias node) => forward(node);

  @override
  visitFunctionTypedFormalParameter(FunctionTypedFormalParameter node) =>
      forward(node);

  @override
  visitGenericFunctionType(GenericFunctionType node) => forward(node);

  @override
  visitGenericTypeAlias(GenericTypeAlias node) => forward(node);

  @override
  visitGuardedPattern(GuardedPattern node) => forward(node);

  @override
  visitHideCombinator(HideCombinator node) => forward(node);

  @override
  visitIfElement(IfElement node) => forward(node);

  @override
  visitIfStatement(IfStatement node) => forward(node);

  @override
  visitImplementsClause(ImplementsClause node) => forward(node);

  @override
  visitImplicitCallReference(ImplicitCallReference node) => forward(node);

  @override
  visitImportDirective(ImportDirective node) => forward(node);

  @override
  visitImportPrefixReference(ImportPrefixReference node) => forward(node);

  @override
  visitIndexExpression(IndexExpression node) => forward(node);

  @override
  visitInstanceCreationExpression(InstanceCreationExpression node) =>
      forward(node);

  @override
  visitIntegerLiteral(IntegerLiteral node) => forward(node);

  @override
  visitInterpolationExpression(InterpolationExpression node) => forward(node);

  @override
  visitInterpolationString(InterpolationString node) => forward(node);

  @override
  visitIsExpression(IsExpression node) => forward(node);

  @override
  visitLabel(Label node) => forward(node);

  @override
  visitLabeledStatement(LabeledStatement node) => forward(node);

  @override
  visitLibraryAugmentationDirective(LibraryAugmentationDirective node) {
    return forward(node);
  }

  @override
  visitLibraryDirective(LibraryDirective node) => forward(node);

  @override
  visitLibraryIdentifier(LibraryIdentifier node) => forward(node);

  @override
  visitListLiteral(ListLiteral node) => forward(node);

  @override
  visitListPattern(ListPattern node) => forward(node);

  @override
  visitLogicalAndPattern(LogicalAndPattern node) => forward(node);

  @override
  visitLogicalOrPattern(LogicalOrPattern node) => forward(node);

  @override
  visitMapLiteralEntry(MapLiteralEntry node) => forward(node);

  @override
  visitMapPattern(MapPattern node) => forward(node);

  @override
  visitMapPatternEntry(MapPatternEntry node) => forward(node);

  @override
  visitMethodDeclaration(MethodDeclaration node) => forward(node);

  @override
  visitMethodInvocation(MethodInvocation node) => forward(node);

  @override
  visitMixinDeclaration(MixinDeclaration node) => forward(node);

  @override
  visitNamedExpression(NamedExpression node) => forward(node);

  @override
  visitNamedType(NamedType node) => forward(node);

  @override
  visitNativeClause(NativeClause node) => forward(node);

  @override
  visitNativeFunctionBody(NativeFunctionBody node) => forward(node);

  @override
  visitNullAssertPattern(NullAssertPattern node) => forward(node);

  @override
  visitNullCheckPattern(NullCheckPattern node) => forward(node);

  @override
  visitNullLiteral(NullLiteral node) => forward(node);

  @override
  visitObjectPattern(ObjectPattern node) => forward(node);

  @override
  visitOnClause(OnClause node) => forward(node);

  @override
  visitParenthesizedExpression(ParenthesizedExpression node) => forward(node);

  @override
  visitParenthesizedPattern(ParenthesizedPattern node) => forward(node);

  @override
  visitPartDirective(PartDirective node) => forward(node);

  @override
  visitPartOfDirective(PartOfDirective node) => forward(node);

  @override
  visitPatternAssignment(PatternAssignment node) => forward(node);

  @override
  visitPatternField(PatternField node) => forward(node);

  @override
  visitPatternFieldName(PatternFieldName node) => forward(node);

  @override
  visitPatternVariableDeclaration(PatternVariableDeclaration node) =>
      forward(node);

  @override
  visitPatternVariableDeclarationStatement(
          PatternVariableDeclarationStatement node) =>
      forward(node);

  @override
  visitPostfixExpression(PostfixExpression node) => forward(node);

  @override
  visitPrefixedIdentifier(PrefixedIdentifier node) => forward(node);

  @override
  visitPrefixExpression(PrefixExpression node) => forward(node);

  @override
  visitPropertyAccess(PropertyAccess node) => forward(node);

  @override
  visitRecordLiteral(RecordLiteral node) => forward(node);

  @override
  visitRecordPattern(RecordPattern node) => forward(node);

  @override
  visitRecordTypeAnnotation(RecordTypeAnnotation node) => forward(node);

  @override
  visitRecordTypeAnnotationNamedField(RecordTypeAnnotationNamedField node) =>
      forward(node);

  @override
  visitRecordTypeAnnotationNamedFields(RecordTypeAnnotationNamedFields node) =>
      forward(node);

  @override
  visitRecordTypeAnnotationPositionalField(
          RecordTypeAnnotationPositionalField node) =>
      forward(node);

  @override
  visitRedirectingConstructorInvocation(
          RedirectingConstructorInvocation node) =>
      forward(node);

  @override
  visitRelationalPattern(RelationalPattern node) => forward(node);

  @override
  visitRepresentationConstructorName(RepresentationConstructorName node) =>
      forward(node);

  @override
  visitRepresentationDeclaration(RepresentationDeclaration node) =>
      forward(node);

  @override
  visitRestPatternElement(RestPatternElement node) => forward(node);

  @override
  visitRethrowExpression(RethrowExpression node) => forward(node);

  @override
  visitReturnStatement(ReturnStatement node) => forward(node);

  @override
  visitScriptTag(ScriptTag node) => forward(node);

  @override
  visitSetOrMapLiteral(SetOrMapLiteral node) => forward(node);

  @override
  visitShowCombinator(ShowCombinator node) => forward(node);

  @override
  visitSimpleFormalParameter(SimpleFormalParameter node) => forward(node);

  @override
  visitSimpleIdentifier(SimpleIdentifier node) => forward(node);

  @override
  visitSimpleStringLiteral(SimpleStringLiteral node) => forward(node);

  @override
  visitSpreadElement(SpreadElement node) => forward(node);

  @override
  visitStringInterpolation(StringInterpolation node) => forward(node);

  @override
  visitSuperConstructorInvocation(SuperConstructorInvocation node) =>
      forward(node);

  @override
  visitSuperExpression(SuperExpression node) => forward(node);

  @override
  visitSuperFormalParameter(SuperFormalParameter node) => forward(node);

  @override
  visitSwitchCase(SwitchCase node) => forward(node);

  @override
  visitSwitchDefault(SwitchDefault node) => forward(node);

  @override
  visitSwitchExpression(SwitchExpression node) => forward(node);

  @override
  visitSwitchExpressionCase(SwitchExpressionCase node) => forward(node);

  @override
  visitSwitchPatternCase(SwitchPatternCase node) => forward(node);

  @override
  visitSwitchStatement(SwitchStatement node) => forward(node);

  @override
  visitSymbolLiteral(SymbolLiteral node) => forward(node);

  @override
  visitThisExpression(ThisExpression node) => forward(node);

  @override
  visitThrowExpression(ThrowExpression node) => forward(node);

  @override
  visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) =>
      forward(node);

  @override
  visitTryStatement(TryStatement node) => forward(node);

  @override
  visitTypeArgumentList(TypeArgumentList node) => forward(node);

  @override
  visitTypeLiteral(TypeLiteral node) => forward(node);

  @override
  visitTypeParameter(TypeParameter node) => forward(node);

  @override
  visitTypeParameterList(TypeParameterList node) => forward(node);

  @override
  visitVariableDeclaration(VariableDeclaration node) => forward(node);

  @override
  visitVariableDeclarationList(VariableDeclarationList node) => forward(node);

  @override
  visitVariableDeclarationStatement(VariableDeclarationStatement node) =>
      forward(node);

  @override
  visitWhenClause(WhenClause node) => forward(node);

  @override
  visitWhileStatement(WhileStatement node) => forward(node);

  @override
  visitWildcardPattern(WildcardPattern node) => forward(node);

  @override
  visitWithClause(WithClause node) => forward(node);

  @override
  visitYieldStatement(YieldStatement node) => forward(node);
}

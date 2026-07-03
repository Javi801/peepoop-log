import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Shows [builder]'s content in a floating bottom card, like the modals of
/// the design reference: detached from the screen edges, fully rounded and
/// scrollable up to 84% of the screen height.
Future<T?> showAppModalSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    // Transparent so the floating card below provides the visible shape.
    backgroundColor: Colors.transparent,
    builder: (context) {
      final colors = context.appColors;
      final decorations = context.appDecorations;

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: AppInsets.modalMargin,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.sizeOf(context).height *
                    AppEffects.modalMaxHeightFraction,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.modal),
                  boxShadow: decorations.modalShadow,
                ),
                padding: AppInsets.modal,
                child: SingleChildScrollView(child: builder(context)),
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Centered modal heading.
class ModalTitle extends StatelessWidget {
  const ModalTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.modalTitle,
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}

/// Bottom row of equally sized modal action buttons.
class ModalActions extends StatelessWidget {
  const ModalActions({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppInsets.modalActions,
      child: Row(
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(child: child),
          ],
        ],
      ),
    );
  }
}

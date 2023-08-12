import 'package:finan_master_app/features/account/domain/entities/account_entity.dart';
import 'package:finan_master_app/features/account/domain/enums/adjustment_option.dart';
import 'package:finan_master_app/features/account/presentation/notifiers/account_notifier.dart';
import 'package:finan_master_app/features/account/presentation/ui/components/confirm_readjust_balance_dialog.dart';
import 'package:finan_master_app/shared/extensions/double_extension.dart';
import 'package:finan_master_app/shared/extensions/string_extension.dart';
import 'package:finan_master_app/shared/presentation/mixins/theme_context.dart';
import 'package:finan_master_app/shared/presentation/ui/app_locale.dart';
import 'package:finan_master_app/shared/presentation/ui/components/dialog/error_dialog.dart';
import 'package:finan_master_app/shared/presentation/ui/components/form/mask/mask_input_formatter.dart';
import 'package:finan_master_app/shared/presentation/ui/components/form/validators/input_required_validator.dart';
import 'package:finan_master_app/shared/presentation/ui/components/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ReadjustBalance extends StatefulWidget {
  final AccountEntity account;

  const ReadjustBalance({Key? key, required this.account}) : super(key: key);

  static Future<AccountEntity?> show({required BuildContext context, required AccountEntity account}) async {
    return await showDialog<AccountEntity?>(
      context: context,
      useSafeArea: false,
      builder: (_) => ReadjustBalance(account: account),
    );
  }

  @override
  State<ReadjustBalance> createState() => _ReadjustBalanceState();
}

class _ReadjustBalanceState extends State<ReadjustBalance> with ThemeContext {
  final AccountNotifier notifier = GetIt.I.get<AccountNotifier>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  double readjustmentValue = 0.0;
  final ValueNotifier<ReadjustmentOption> readjustmentOption = ValueNotifier(ReadjustmentOption.createTransaction);
  String? transactionDescription;

  @override
  void initState() {
    super.initState();
    notifier.setAccount(widget.account);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: ValueListenableBuilder(
        valueListenable: notifier,
        builder: (_, state, __) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: context.pop,
                tooltip: strings.close,
                icon: const Icon(Icons.close_outlined),
              ),
              title: Text(strings.balanceReadjustment),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: TextButton(
                    onPressed: save,
                    child: Text(strings.save),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.zero,
                child: notifier.isLoading ? const LinearProgressIndicator() : const SizedBox(height: 4),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacing.y(2),
                    TextFormField(
                      initialValue: notifier.account.balance.moneyWithoutSymbol,
                      decoration: InputDecoration(label: Text(strings.accountBalance), prefixText: NumberFormat.simpleCurrency(locale: R.locale.toString()).currencySymbol),
                      validator: InputRequiredValidator().validate,
                      enabled: !notifier.isLoading,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onSaved: (String? value) => readjustmentValue = (value ?? '').moneyToDouble(),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, MaskInputFormatter.currency()],
                    ),
                    const Spacing.y(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(strings.initialAccountBalance, style: textTheme.bodySmall?.copyWith(color: colorScheme.outline)),
                        Text(notifier.account.initialValue.money, style: textTheme.labelMedium?.copyWith(color: colorScheme.outline)),
                      ],
                    ),
                    const Spacing.y(),
                    ValueListenableBuilder(
                      valueListenable: readjustmentOption,
                      builder: (_, value, __) {
                        return Column(
                          children: [
                            IntrinsicHeight(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Card(
                                      elevation: 0,
                                      margin: EdgeInsets.zero,
                                      clipBehavior: Clip.hardEdge,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(color: value == ReadjustmentOption.createTransaction ? colorScheme.primary : colorScheme.outline),
                                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          if (notifier.isLoading) return;
                                          readjustmentOption.value = ReadjustmentOption.createTransaction;
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(strings.createTransaction, style: textTheme.titleMedium?.copyWith(color: value == ReadjustmentOption.createTransaction ? colorScheme.primary : null)),
                                              const Spacing.y(0.5),
                                              Text(strings.createTransactionExplication, style: textTheme.bodySmall?.copyWith(color: colorScheme.outline)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Card(
                                      elevation: 0,
                                      margin: EdgeInsets.zero,
                                      clipBehavior: Clip.hardEdge,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(color: value == ReadjustmentOption.changeInitialValue ? colorScheme.primary : colorScheme.outline),
                                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          if (notifier.isLoading) return;
                                          readjustmentOption.value = ReadjustmentOption.changeInitialValue;
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(strings.changeInitialValue, style: textTheme.titleMedium?.copyWith(color: value == ReadjustmentOption.changeInitialValue ? colorScheme.primary : null)),
                                              const Spacing.y(0.5),
                                              Text(strings.changeInitialValueExplication, style: textTheme.bodySmall?.copyWith(color: colorScheme.outline)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacing.y(),
                            TextFormField(
                              decoration: InputDecoration(label: Text(strings.transactionDescription)),
                              textInputAction: TextInputAction.done,
                              enabled: !notifier.isLoading && readjustmentOption.value == ReadjustmentOption.createTransaction,
                              onSaved: (String? value) => transactionDescription = value,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> save() async {
    try {
      if (notifier.isLoading) return;

      if (formKey.currentState?.validate() ?? false) {
        formKey.currentState?.save();

        if (notifier.account.balance == readjustmentValue) {
          context.pop();
          return;
        }

        final double valueDialog = readjustmentOption.value == ReadjustmentOption.changeInitialValue ? readjustmentValue : notifier.account.balance - readjustmentValue;

        final bool confirm = await ConfirmReadjustBalanceDialog.show(context: context, value: valueDialog, option: readjustmentOption.value);
        if (!confirm) return;

        await notifier.readjustBalance(readjustmentValue: readjustmentValue, option: readjustmentOption.value, description: transactionDescription);

        if (!mounted) return;
        context.pop(notifier.account);
      }
    } catch (e) {
      await ErrorDialog.show(context, e.toString());
    }
  }
}

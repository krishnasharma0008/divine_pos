// lib/features/verify_track/screens/tabs/insurance_screen.dart

import 'package:flutter/material.dart';
import '../../data/verify_track_model.dart';
import '../verify_detail_shell.dart';

enum _InsuranceStep { info, form, done }

class InsuranceScreen extends StatefulWidget {
  final VerifyTrackByUid product;
  const InsuranceScreen({super.key, required this.product});

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> {
  _InsuranceStep _step = _InsuranceStep.info;

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _InsuranceStep.info:
        return _buildInfo();
      case _InsuranceStep.form:
        return _buildForm();
      case _InsuranceStep.done:
        return _buildDone();
    }
  }

  Widget _buildInfo() {
    final p = widget.product;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Banner with UID
          VtCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'UID: ${p.uid}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMid,
                      ),
                    ),
                    Text(
                      p.productType,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mintDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.textDark, Color(0xFF333333)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shield_outlined,
                      size: 44,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Features
          VtCard(
            child: Column(
              children: [
                _Feature(
                  icon: Icons.verified_user_outlined,
                  title: 'FREE INSURANCE FOR 1 YEAR',
                ),
                const Divider(color: AppColors.divider),
                _Feature(
                  icon: Icons.assignment_outlined,
                  title: 'EASY CLAIM PROCESS',
                  link: 'Read More',
                ),
                const Divider(color: AppColors.divider),
                _Feature(
                  icon: Icons.description_outlined,
                  title: 'TERMS & CONDITIONS',
                  link: 'Read More',
                ),
              ],
            ),
          ),

          VtCard(
            child: SizedBox(
              width: double.infinity,
              child: VtFilledButton(
                label: 'APPLY',
                onPressed: () => setState(() => _step = _InsuranceStep.form),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final p = widget.product;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: VtCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const VtSectionTitle('Personal Information'),
            const VtFormField(label: 'Name*'),
            const VtFormField(label: 'Email Id*'),
            const VtFormField(label: 'Mobile No*'),
            const VtFormField(label: 'Address*'),
            const VtFormField(label: 'Pin Code*'),
            const VtFormField(label: 'Date of Birth*', isDate: true),
            const VtFormField(label: 'Anniversary Date*', isDate: true),
            const SizedBox(height: 16),
            const VtSectionTitle('Product Information'),
            // Pre-filled from product data
            VtFormField(label: 'UID*', initialValue: p.uid, readOnly: true),
            VtFormField(
              label: 'Product Value',
              initialValue: formatInr(p.currentPrice),
              readOnly: true,
            ),
            const VtFormField(label: 'Invoice Number*'),
            const VtFormField(label: 'Invoice Value*'),
            const VtFormField(label: 'Invoice Date*', isDate: true),
            const VtFormField(label: 'PAN Number'),
            const SizedBox(height: 12),
            const VtUploadBox(label: 'Upload Address Proof'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: VtOutlineButton(
                    label: 'CANCEL',
                    onPressed: () =>
                        setState(() => _step = _InsuranceStep.info),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: VtFilledButton(
                    label: 'SUBMIT',
                    onPressed: () =>
                        setState(() => _step = _InsuranceStep.done),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDone() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: VtCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.diamond_outlined,
                size: 56,
                color: AppColors.mintDark,
              ),
              const SizedBox(height: 12),
              const Text(
                'Thank You!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your request is under process.',
                style: TextStyle(fontSize: 12, color: AppColors.textMid),
              ),
              const SizedBox(height: 20),
              VtFilledButton(
                label: 'HOME',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? link;
  const _Feature({required this.icon, required this.title, this.link});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, size: 20, color: AppColors.mintDark),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            if (link != null)
              Text(
                link!,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.mintDark,
                  decoration: TextDecoration.underline,
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

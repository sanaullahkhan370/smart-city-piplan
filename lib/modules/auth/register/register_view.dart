import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'register_controller.dart';

class RegisterView
    extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller:
                    controller.nameController,
                    textInputAction:
                    TextInputAction.next,
                    decoration:
                    const InputDecoration(
                      labelText: 'Name',
                      prefixIcon:
                      Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator:
                    controller.validateName,
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller:
                    controller.emailController,
                    keyboardType:
                    TextInputType.emailAddress,
                    textInputAction:
                    TextInputAction.next,
                    decoration:
                    const InputDecoration(
                      labelText: 'Email',
                      prefixIcon:
                      Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator:
                    controller.validateEmail,
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller:
                    controller.phoneController,
                    keyboardType:
                    TextInputType.phone,
                    textInputAction:
                    TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly,
                      LengthLimitingTextInputFormatter(
                        13,
                      ),
                    ],
                    decoration:
                    const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '03001234567',
                      prefixIcon:
                      Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    validator:
                    controller.validatePhone,
                  ),

                  const SizedBox(height: 15),

                  Obx(
                        () => TextFormField(
                      controller: controller
                          .passwordController,
                      obscureText: controller
                          .isPasswordHidden.value,
                      textInputAction:
                      TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!controller
                            .isLoading.value) {
                          controller.register();
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon:
                        const Icon(Icons.lock),
                        border:
                        const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: controller
                              .togglePasswordVisibility,
                          icon: Icon(
                            controller
                                .isPasswordHidden
                                .value
                                ? Icons.visibility
                                : Icons
                                .visibility_off,
                          ),
                        ),
                      ),
                      validator:
                      controller.validatePassword,
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(
                          () => ElevatedButton(
                        onPressed:
                        controller.isLoading.value
                            ? null
                            : controller.register,
                        child: controller
                            .isLoading.value
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'Register',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}